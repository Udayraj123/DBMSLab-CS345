#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define ll long int

// directory reading - 
#include <sys/types.h>
#include <dirent.h>
DIR *opendir(const char *name);

// int strequal(char * s, char * s2, int n){
// 	for (int i = 0; i < n; ++i)
// 	{
// 		if(s[i]!=s2[i])
// 			return 0;
// 	}
// 	return 1;
// }

typedef struct courseNode
{
	struct courseNode *next = NULL;
	char course_id[6];
} courseNode;

typedef struct entry
{
	int roll;
	char* name;
	courseNode* coursesHead;
	// char* email; Not used anywhere in code
} Entry;


char* concat(const char *s1, const char *s2)
{
    char *result = (char*)malloc(strlen(s1)+strlen(s2)+1);//+1 for the null-terminator
    //in real course_id you would check for errors in malloc here
    strcpy(result, s1);
    strcat(result, s2);
    return result;
}
courseNode* createCourseNode(char* course_id){
	courseNode* newNode = (courseNode*)malloc(sizeof(courseNode));
	strcpy(newNode->course_id,course_id);
	return newNode;
}

int hashRoll(int roll, int min_roll){
	return roll - min_roll;
}

void flushFile(char *name){
	FILE* fp = fopen(name,"w");
	fprintf(fp, "%s", ""); // flush file
	fclose(fp);

}

/*
Assumptions-
1) Each course in exam timetable appears exactly 2 times (midsem + endsem).
2] First 2 char of dept folder & dept course name are same (case in-sensitive tho)
	directory reading = string concat & then listDir to load csv file names inside.
3] course_id's are at max 6 characters
4] The course folders have unique entries of students

THIS CODE WILL STILL WORK WHEN-
1) Adding a new department folder with any number of course files



354 x numStudents memory will be required in the program
-> Need to use free() at places

M1) List conflicting courses for a student (600+ students)
-> But you do not know the roll numbers or their pattern!
-> yet, make a 2D array to know, use bruteforce to check unique

M2) List conflicting students for a course (constant - 354 courses)
	i. function to load all students in a particular course
	-> while merging you'll find the conflict immediately 
	(MAKE A STRUCT WITH LINKED LIST FOR COURSES)

-> You do have a list of courses tho
-> But still you have to sum up the credits per student
	i. function to list all courses of a student. Also sum up credits of these at same time
nope 2. check pairwise (NC2) for clashes of time
done	i. function to retrieve date & time-duration
done	ii. function to check overlapping times

List all the roll numbers (along with names of the student) who
violate the following two important registration constraints:
i.  A registered student should not have exam time table clash with his/her
set of registered courses.  If there are any exam time table clashes, list the
roll number and student name and the two courses having exam time table
clash.
ii.  Total  number  of  credits  registered  should  not  exceed  40.   List  the  roll
number,  student  name  and  total  number  of  credits  registered  who  have
violated this constraint
	*/
int digit(char digit){
	return digit - '0';
}


// can use comparator function here, but clumsy
int loadMidSemExamTime(char *course_name, char* exam_date, int* startNum, int* endNum){
	FILE* fp = fopen("exam-time-table.csv","r");
	char* course,*start,*end;
	while(!feof(fp)){
	// Note - %s consumes the ',' as well! use %[^,]
		fscanf(fp,"%[^,],%[^,],%[^,],%s",course,exam_date,start,end);
		if(strcmp(course,course_name) &&
			 digit(exam_date[6]) < 4){// midsem criteria
			*startNum = digit(start[0])*1000 + digit(start[1])*100 + digit(start[3])*10 + digit(start[4]);//four digits 
			*endNum   = digit(end[0])*1000 + digit(end[1])*100 + digit(end[3])*10 + digit(end[4]);//four digits 
			return 1;			
		}
	}
	fclose(fp);
	return 0; //failed to find. Should not reach here!

}
int loadEndSemExamTime(char *course_name, char* exam_date, int* startNum, int* endNum){
	FILE* fp = fopen("exam-time-table.csv","r");
	char* course,*start,*end;
	while(!feof(fp)){
	// Note - %s consumes the ',' as well! use %[^,]
		fscanf(fp,"%[^,],%[^,],%[^,],%s",course,exam_date,start,end);
		if(strcmp(course,course_name) &&
			 digit(exam_date[6]) > 3){// endsem criteria
			*startNum = digit(start[0])*1000 + digit(start[1])*100 + digit(start[3])*10 + digit(start[4]);//four digits 
			*endNum   = digit(end[0])*1000 + digit(end[1])*100 + digit(end[3])*10 + digit(end[4]);//four digits 
			return 1;			
		}
	}
	fclose(fp);
	printf("failed to find. Should not reach here!\n");
	return 0; //failed to find. Should not reach here!

}
int checkEndSemOverlap(char *course1,char *course2){
	char *date1,*date2;
	int start1,end1, start2,end2;
	if(loadEndSemExamTime(course1,date1,&start1,&end1) && loadEndSemExamTime(course2,date2,&start2,&end2)){
		if(strcmp(date1,date2)){
			//time overlap
			if( (start2 < end1 && start1 < end2 ) )
				return 0;
		}
	}
	else{
		//failed to load timings
		return 0;
	}
	return 1;
}

int checkMidSemOverlap(char *course1,char *course2){
	char *date1,*date2;
	int start1,end1, start2,end2;
	if(loadMidSemExamTime(course1,date1,&start1,&end1) && loadMidSemExamTime(course2,date2,&start2,&end2)){
		if(strcmp(date1,date2)){
			//time overlap
			if( (start2 < end1 && start1 < end2 ) )
				return 0;
		}
	}
	else{
		//failed to load timings
		return 0;
	}
	return 1;
}

int checkOverlap(char *course1,char *course2){
	return checkMidSemOverlap(course1,course2) && checkEndSemOverlap(course1,course2);
}


courseNode*  insertNCheckCourse(char* course_id, Entry* student){
	// courseNode* head
	courseNode* temp = student->coursesHead;
	courseNode* newNode = createCourseNode(course_id);
	if(temp == NULL){// first node
		return newNode;
	}
	while(temp->next!=NULL){
		// check also
		if(strcmp(course_id,temp->course_id)){
			//just a check
			printf("WARNING : Duplicate course entry found! in course %s for roll %d", course_id,student->roll);
		}
		if(checkOverlap(course_id,temp->course_id)){
			//print the roll wagera here
			printf("Clash found for student %s (%d) in courses %s & %s", student->name,student->roll, course_id, temp->course_id);
		}
		temp=temp->next;
	}
	//reach end
	temp->next = newNode;
	return student->coursesHead;
}
Entry * newEntry(int roll, char* name, char* email){
	Entry* newNode = (Entry*)malloc(sizeof(Entry));
	newNode->roll = roll;
	newNode->name = name;
	// newNode->email = email; // unused

	printf("Added entry: %d, %s, %s\n",roll, name, email);

	return newNode;
}
// RATE DETERMINING STEP : 
void addEntries(char * course_id,char* filepath, Entry* entries[], int* num_entries){
	// read each csv, check for unique and append the course nodes to each stud.
	// on unique conflict, check for overlap & output if clash
	FILE* fp = fopen(filepath,"r");
	int serialno,roll,flag;
	char* name,*email;
	while(!feof(fp)){
		fscanf(fp,"%d,%d,%[^,],%s",&serialno,&roll,name,email);
		flag =0 ;
		for (int i = 0; i < *num_entries; ++i)
		{
			if(entries[i]->roll == roll){
				flag = 1;
				entries[i]->coursesHead = insertNCheckCourse(course_id,entries[i]);

				break;
			}
		}
		if(flag == 0){
			//new entry
			entries[*num_entries] = newEntry(roll,name,email);
			*num_entries = *num_entries + 1;
		}
	}
	fclose(fp);
}

void openCourseFiles(char* directory,Entry* entries[], int* num_entries){

	DIR *dp = NULL;
	struct dirent *dptr = NULL;
	char* filepath = concat("course-wise-students-list/",directory);
	char * course_id;
    // Open the directory stream
	if(NULL == (dp = opendir(filepath)) )
	{
		printf("\n Cannot open Input directory [%s]\n",directory);
		exit(1);
	}
	else
	{
        // Read the directory contents
		while(NULL != (dptr = readdir(dp)) )
		{
			//call load csv here
			course_id = dptr->d_name;
		    course_id[strlen(course_id)-4] = '\0';// remove the .csv from filename
		    addEntries(course_id, concat(filepath,dptr->d_name), entries,num_entries);
		}
		closedir(dp);
	}
}

void openDeptFolders(Entry* entries[], int* num_entries){
	DIR *dp = NULL;
	struct dirent *dptr = NULL;
    // Open the directory stream
	if(NULL == (dp = opendir("course-wise-students-list")) )
	{
		printf("\n Cannot open Input directory [%s]\n","course-wise-students-list");
		exit(1);
	}
	else
	{
        // Read the directory contents
		while(NULL != (dptr = readdir(dp)) )
		{
			if( !strcmp(dptr->d_name,".") && !strcmp(dptr->d_name,"..")){
				// now call a function to load course files in each dept
				openCourseFiles(dptr->d_name,entries,num_entries);
				printf(" [%s]  Loaded \n",dptr->d_name);
			}
		}
        // Close the directory stream
		closedir(dp);
	}

}

int getCredits(char* course_id){

	FILE* fp = fopen("course-credits.csv","r");
	char* course;
	int credits;
	while(!feof(fp)){
		fscanf(fp,"%[^,],%d",course,&credits);
		if(strcmp(course,course_id))
			return credits;			
	}
	fclose(fp);
	// 
	printf("Course credits not found for %s\n", course_id);

}

int main(){
	int max_num_entries  = 5000;
	int num_entries = 0;
	Entry* entries[num_entries];
// 	openDeptFolders(entries,&num_entries);

// 	courseNode* temp;
// 	int sum;
// //after loading all entries, do a O(n) traversal for summing the credits
// 	for (int i = 0; i < num_entries; ++i) {
// 		temp == entries[i]->coursesHead;
// 		sum =0 ;
// 		while(temp!=NULL){
// 			sum += getCredits(temp->course_id);
// 			temp = temp->next;
// 		}
// 		if(sum>40){
// 			// print
// 			printf("Max Credits exceeded for student %s (%d) : Total credits = %d \n", entries[i]->name,entries[i]->roll,sum);
// 			printf("Courses taken by %d : ",entries[i]->roll );
// 			temp == entries[i]->coursesHead;
// 			while(temp!=NULL){
// 				printf("%s(%d) \t",temp->course_id,getCredits(temp->course_id));
// 				temp = temp->next;
// 			}
// 			printf("\n");
// 		}
// 	}

	printf("Finished processing.    \n");
	return 0;
}
/*

//template function
void listDir(char* directory){
	
	DIR *dp = NULL;
	struct dirent *dptr = NULL;
    // Open the directory stream
	if(NULL == (dp = opendir(directory)) )
	{
		printf("\n Cannot open Input directory [%s]\n",directory);
		exit(1);
	}
	else
	{
		printf("\n The contents of directory [%s] are as follows \n",directory);
        // Read the directory contents
		while(NULL != (dptr = readdir(dp)) )
		{
			if( !strcmp(dptr->d_name,".") && !strcmp(dptr->d_name,".."))
				printf(" [%s] ",dptr->d_name);
		}
        // Close the directory stream
		closedir(dp);
	}
}

*/