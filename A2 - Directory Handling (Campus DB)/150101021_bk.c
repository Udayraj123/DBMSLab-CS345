#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// directory reading - 
#include <sys/types.h>
#include <dirent.h>
DIR *opendir(const char *name);

#define ll long int
#define max_num_entries  4500
#define max_num_courses  500
#define MAX_STR_LEN 300
#define SMALL_STR 8//courses, start,end etc
#define ROLL_LEN 11

#define DEBUG_MODE
#ifdef DEBUG_MODE
int PRINT_ALLOW = 1;
#else
int PRINT_ALLOW = 0;
#endif
#define dprintf(...) if(PRINT_ALLOW)printf(__VA_ARGS__);


typedef struct creditCourse{
	int credits;
	char course_id[SMALL_STR];
} creditCourse;

typedef struct courseNode
{
	struct courseNode *next;// = NULL;
	char course_id[SMALL_STR];//include null
} courseNode;
typedef struct entry
{
	char roll[ROLL_LEN];
	char name[MAX_STR_LEN];
	// char courses[10][SMALL_STR]; //alternative
	courseNode* coursesHead;
	// char * email; Not used anywhere in code
} Entry;

courseNode* createCourseNode(char * course_id){
	courseNode* newNode = (courseNode*)malloc(sizeof(courseNode));
	newNode->next = NULL;
	strcpy(newNode->course_id,course_id);
	return newNode;
}

/*
Assumptions-
1) Each course in exam timetable appears exactly 2 times (midsem + endsem).
2] First 2 char of dept folder & dept course name are same (case in-sensitive tho)
	directory reading = string concat & then listDir to load csv file names inside.
3] course_id's are at max 6 characters
4] The course csv files have unique entries of students i.e. one student can take a course only once in a term.

THIS CODE WILL STILL WORK WHEN-
1) Adding a new department folder with any number of course files

NOTE : 
1) Some email fields are empty - no problem, coz the comma is still there. Newlines though, need to be handled
2) 91 courses do not exist in exam-time-table as they are lab courses. only 354 theory courses are present.
   -> If a course doesn't exist in time-table, ignore if its a lab course else give an error.



445 x numStudents memory will be required in the program
-> Need to use free() at places

M1) List conflicting courses for a student (600+ students)
-> But you do not know the roll numbers or their pattern!
-> yet, make a 2D array to know, use bruteforce to check unique

M2) List conflicting students for a course (constant - 445 courses)
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

// the \n must get consumed, otherwise next entry's first character will be a '\n'

	*/
int digit(char digit){
	return digit - '0';
}


// can use comparator function here, but clumsy
int loadExamTime(char *course_name, char * exam_date, int* startNum, int* endNum,int lowerM,int upperM){
	FILE* fp = fopen("exam-time-table.csv","r");
	char course[SMALL_STR],start[SMALL_STR],end[SMALL_STR];
	fgetc(fp);
	while(!feof(fp)){
		fseek(fp,-1,SEEK_CUR);
		fscanf(fp,"%[^,],%[^,],%[^,],%[^\n]",course,exam_date,start,end);
		if(strcmp(course,course_name)==0 &&
			digit(exam_date[6]) < upperM && 
				 digit(exam_date[6]) > lowerM){// criteria
			*startNum = digit(start[0])*1000 + digit(start[1])*100 + digit(start[3])*10 + digit(start[4]);//four digits 
			*endNum   = digit(end[0])*1000 + digit(end[1])*100 + digit(end[3])*10 + digit(end[4]);//four digits 
			// dprintf("Exam for %s is on %s from %d to %d \n",course, exam_date,*startNum,*endNum);
			{

				fclose(fp);
				return 1;
			}	

		}
		fgetc(fp);
		fgetc(fp);
	}

	fclose(fp);

// Handle lab course case here - 
	// check in credits file later
	if(1)
		// TODO 
		return -1;
	else{

		printf("Failed to find course. Should not reach here!\n");
		return 0; //failed to find. Should not reach here!
	}

}
int checkExamOverlap(char *course1,char *course2,int lowerM,int upperM){
	char date1[11],date2[11];
	int start1,end1, start2,end2;
	int load1= loadExamTime(course1,date1,&start1,&end1,lowerM,upperM);
	int load2= loadExamTime(course2,date2,&start2,&end2,lowerM,upperM);
	if( load1 ==1 && load2==1 ){
		if(strcmp(date1,date2) == 0){
			//time overlap
			if( (start2 < end1 && start1 < end2 ) )
				return 0;
		}
	}
	else if (load1 == -1 || load2 == -1){
		//One of em is a Lab course, ignore
		return 1;//clean
	}
	else{

		//failed to load timings
		return 0;
	}
	return 1;//clean, no overlap
}

int checkOverlap(char *course1,char *course2){
	// dprintf("Checking clash for %s & %s \n",course1, course2);
	return checkExamOverlap(course1,course2,1,4) && checkExamOverlap(course1,course2,3,6);
}

Entry * newEntry(char * roll, char * name, char * email){
	Entry* newNode = (Entry*)malloc(sizeof(Entry));
	newNode->coursesHead = NULL; //added 11:14pm
	strcpy(newNode->roll,roll);
	strcpy(newNode->name,name);
	// strcpy(newNode->email,email);//unused

	// dprintf("Added entry: %s, %s\n",newNode->roll, newNode->name);

	return newNode;
}


char * concat(const char *s1, const char *s2)
{
    char *result = (char *)malloc(strlen(s1)+strlen(s2)+1);//+1 for the null-terminator
    //in real course_id you would check for errors in malloc here
    strcpy(result, s1);
    strcat(result, s2);
    return result;
}
void removeLast(char *s, int k){
	if(k>strlen(s))return;
	s[strlen(s)-k]='\0';
}

void takeFirst(char *s, int k){
	if(k>strlen(s))return;
	s[k]='\0';
}


courseNode*  insertNCheckCourse(char * course_id, Entry* student){
	// dprintf("\t>>Insert checking creditCourse %s for %s\n",course_id, student->roll);
	// courseNode* head
	courseNode* newNode = createCourseNode(course_id);

	if(student->coursesHead == NULL){ //first node
		student->coursesHead = newNode;
		return newNode;
	}
	courseNode* temp = student->coursesHead;

	// dprintf("Courses by %s : ",student->roll);		
	while(temp->next != NULL){
		// dprintf("%s \t",temp->course_id);
		// if(strcmp(course_id,temp->course_id)==0){//just a check
		// 	printf("WARNING : Duplicate course entry found! in course %s for roll %s\n", course_id,student->roll);
		// 	return student->coursesHead;
		// }
		// if(checkOverlap(course_id,temp->course_id) == 0){//print the roll wagera here
		// 	printf("Clash found for student %s (%s) in courses %s & %s\n", student->name,student->roll, course_id, temp->course_id);
		// }
		temp=temp->next;
	}
	// if(strcmp(course_id,temp->course_id)==0){//just a check
	// 	printf("WARNING : Duplicate course entry found! in course %s for roll %s\n", course_id,student->roll);
	// 	return student->coursesHead;
	// }
	// if(checkOverlap(course_id,temp->course_id) == 0){//print the roll wagera here
	// 	printf("Clash found for student %s (%s) in courses %s & %s\n", student->name,student->roll, course_id, temp->course_id);
	// }
	// dprintf("\n");
	temp->next = newNode;
	return student->coursesHead;
}
// RATE DETERMINING STEP : 
void addEntries(char * course_id,char * filepath, Entry* entries[], int* num_entries){
	// read each csv, check for unique and append the course nodes to each stud.
	// on unique conflict, check for overlap & output if clash
	FILE* fp = fopen(filepath,"r");
	int i,serialno,flag;
	char roll[ROLL_LEN], name[MAX_STR_LEN], email[MAX_STR_LEN];
	fgetc(fp);
	// dprintf("scanning %s\n", course_id);
	while(!feof(fp)){
		fseek(fp,-1,SEEK_CUR);
		fscanf(fp,"%d,%[^,],%[^,],%[^\n,]",&serialno,roll, name,email);

		// dprintf("%d,%s,%s\n",serialno,roll, name);
		flag =0 ;
		for (i = 0; i < *num_entries; ++i)
		{
			if(strcmp(entries[i]->roll,roll)==0){
				flag = 1;
				entries[i]->coursesHead = insertNCheckCourse(course_id,entries[i]);
				break;
			}
		}
		if(flag == 0){
			//new entry
			entries[*num_entries] = newEntry(roll,name,email);
			entries[*num_entries]->coursesHead = insertNCheckCourse(course_id,entries[*num_entries]);
			*num_entries = *num_entries + 1;
		}
		fgetc(fp);
		fgetc(fp);
	}

	fclose(fp);
}
void openCourseFiles(char * directory,Entry* entries[], int* num_entries){

	DIR *dp = NULL;
	struct dirent *dptr = NULL;
	char  course_id[SMALL_STR+5];
    // Open the directory stream
	char * filepath = concat(concat("course-wise-students-list/",directory),"/");
	dprintf("%d)%s\n",*num_entries, filepath);
	if(NULL == (dp = opendir(filepath)) )
	{
		printf("\n Cannot open Input directory [%s]\n",directory);
		exit(1);
	}

	//C:\Users\Udayraj021\Downloads\coding\DBMSLab

	else
	{
        // Read the directory contents
		while(NULL != (dptr = readdir(dp)) )
		{
			if( strcmp(dptr->d_name,".") && strcmp(dptr->d_name,"..")){
		    // remove the .csv from filename
				strcpy(course_id,dptr->d_name);
				removeLast(course_id,4);
				// dprintf("%d) %s  %s\n", *num_entries, course_id, concat(filepath,dptr->d_name));
				addEntries(course_id, concat(filepath,dptr->d_name), entries,num_entries);
			}
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
			if( strcmp(dptr->d_name,".") && strcmp(dptr->d_name,"..")){
				// now call a function to load course files in each dept
				dprintf(" Scraping directory [%s]   \n",dptr->d_name);
				openCourseFiles(dptr->d_name,entries,num_entries);
			}
		}
        // Close the directory stream
		closedir(dp);
	}

}

int loadCredits(creditCourse courses[]){
	FILE* fp = fopen("course-credits.csv","r");
	char course[SMALL_STR];
	int i = 0;
	fgetc(fp);
	while(!feof(fp)){
		fseek(fp,-1,SEEK_CUR);

		fscanf(fp,"%[^,],%d",courses[i].course_id, &courses[i].credits);

		fgetc(fp);
		fgetc(fp);
		i++;
	}
	fclose(fp);
	return i+1;
}

int getCredits(char * course_id, creditCourse courses[], int num_courses){
	int i;
	for (i = 0; i < num_courses; ++i){
		// dprintf("%s - %d\n", courses[i].course_id, courses[i].credits);
		if(strcmp(courses[i].course_id,course_id)==0){
			return courses[i].credits;			
		}
	}
	printf("ERROR: creditCourse credits not found for %s\n", course_id);
	return 999;
}

int main(){
	creditCourse courses[max_num_courses];
	int num_courses = loadCredits(courses);
	printf("%d Courses loaded\n", num_courses);
	// //test getCredits
	// char course1[SMALL_STR]="BT101"; 
	// char course2[SMALL_STR]="PH706"; 
	// dprintf("\nBegin test\n");
	// dprintf("credits for course1 %s = %d\n", course1, getCredits(course1,courses,num_courses));
	// dprintf("credits for course2 %s = %d\n", course2, getCredits(course2,courses,num_courses));
	// dprintf("Overlap check : %d", !checkOverlap(course1,course2));
	// dprintf("\nEnd test\n");

	Entry* entries[max_num_entries];
	int num_entries = 0;//initial
	openDeptFolders(entries,&num_entries);
	printf("%d\n", num_entries);


	courseNode* temp;
	int sum,i;
	int crcounter = 1;
//after loading all entries, do a O(n) traversal for summing the credits
	for (i = 0; i < num_entries; ++i) {
		temp = entries[i]->coursesHead;
		sum =0 ;
		while(temp!=NULL){
			sum += getCredits(temp->course_id,courses,num_courses);
			temp = temp->next;
		}
		if(sum>40){
			// print
			printf("%d)Max Credits exceeded for student %s (%s) : Total credits = %d \n", crcounter++, entries[i]->name,entries[i]->roll,sum);
			printf("Courses taken by %s : ",entries[i]->roll );
			temp = entries[i]->coursesHead;
			while(temp!=NULL){
				printf("%s(%d)  ",temp->course_id,getCredits(temp->course_id,courses,num_courses));
				temp = temp->next;
			}
			printf("\n");
		}
	}

	// printf("Finished processing.    \n");
	return 0;
}