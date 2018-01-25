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
#define SMALL_STR 11//courses, start,end etc
#define ROLL_LEN 11

#define DEBUG_MODE
#ifdef DEBUG_MODE
int PRINT_ALLOW = 1;
#else
int PRINT_ALLOW = 0;
#endif
#define dprintf(...) if(PRINT_ALLOW)printf(__VA_ARGS__);


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
1] course_id's are at max 6 characters
2] The course csv files have unique entries of students i.e. one student can take a course only once in a term.
3] This code is compiled and run just outside the "course-wise-students" directory
THIS CODE WILL STILL WORK WHEN-
1) Adding a new department folder with any number of course files (just that each file should end with a newline)

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

typedef struct creditCourse{
	int credits, startNumMS, endNumMS,startNumES, endNumES;
	char course_id[SMALL_STR];
	char exam_date[SMALL_STR];
} creditCourse;

void loadCredits(creditCourse courses[], int * num_courses){
	FILE* fp = fopen("course-credits.csv","r");
	char course[SMALL_STR];
	int i = 0;
	fgetc(fp);
	while(!feof(fp)){
		fseek(fp,-1,SEEK_CUR);

		fscanf(fp,"%[^,],%d",courses[i].course_id, &courses[i].credits);
		// defaults - 
		courses[i].startNumMS = 0;
		courses[i].startNumES = 0;
		courses[i].endNumMS = 0;
		courses[i].endNumES = 0;
		strcpy(courses[i].exam_date,"0000-00-00");//no clash date

		fgetc(fp);
		fgetc(fp);
		i++;
	}
	fclose(fp);
	*num_courses = *num_courses + i;
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

int searchCourse(char* course, creditCourse courses[], int num_courses){
	int i;
	for ( i = 0; i < num_courses; ++i){
		if(strcmp(courses[i].course_id,course)==0)
			return i;
	}
	return -1;
}

int loadExamTimeTable(creditCourse courses[], int * num_courses){
	FILE* fp = fopen("exam-time-table.csv","r");
	char course[SMALL_STR],start[SMALL_STR],end[SMALL_STR],exam_date[SMALL_STR];
	fgetc(fp);
	int  course_index,startNum,endNum;
	while(!feof(fp)){
		fseek(fp,-1,SEEK_CUR);
		fscanf(fp,"%[^,],%[^,],%[^,],%[^\n]",course,exam_date,start,end);
		startNum = digit(start[0])*1000 + digit(start[1])*100 + digit(start[3])*10 + digit(start[4]);//four digits 
		endNum   = digit(end[0])*1000 + digit(end[1])*100 + digit(end[3])*10 + digit(end[4]);//four digits 

// search for 'course' in array, if not found, append it.
		course_index = searchCourse(course,courses,*num_courses);
		if(course_index==-1){
			// new course entry
			courses[*num_courses].credits = 0;

			strcpy(courses[*num_courses].course_id, course);
			course_index = *num_courses;
			*num_courses = *num_courses + 1;
		}
		strcpy(courses[course_index].exam_date, exam_date);
		// set datetime
		if(digit(exam_date[6]) < 4 ){//MS
			courses[course_index].startNumMS = startNum;
			courses[course_index].endNumMS = endNum;
		}else{
			courses[course_index].startNumES = startNum;
			courses[course_index].endNumES = endNum;
		}
		fgetc(fp);
		fgetc(fp);
	}

	fclose(fp);
}

int checkExamOverlap(char *course1,char *course2,creditCourse courses[], int num_courses){
	int index1,index2;
	index1 = searchCourse(course1,courses,num_courses);
	index2 = searchCourse(course2,courses,num_courses);
	if(index1== -1){printf("Course not found : %s\n", course1);return 1;}
	if(index2== -1){printf("Course not found : %s\n", course2);return 1;}
	
	if(strcmp(courses[index1].exam_date, "0000-00-00") != 0 && 
		strcmp(courses[index1].exam_date, courses[index2].exam_date) == 0){
		
		if( courses[index1].startNumMS * courses[index2].startNumMS && 
			courses[index1].endNumMS * courses[index2].endNumMS && 
			courses[index1].startNumMS < courses[index2].endNumMS && 
			courses[index2].startNumMS < courses[index1].endNumMS  ){

			// printf("Midsem clash : %d-%d, %d-%d\n",courses[index1].startNumMS,courses[index1].endNumMS,courses[index2].startNumMS,courses[index2].endNumMS);
		return 0;
	}

	if( courses[index1].startNumES * courses[index2].startNumES && 
		courses[index1].endNumES * courses[index2].endNumES && 
		courses[index1].startNumES < courses[index2].endNumES && 
		courses[index2].startNumES < courses[index1].endNumES  ){

		// printf("Endsem clash : %d-%d, %d-%d\n",courses[index1].startNumES,courses[index1].endNumES,courses[index2].startNumES,courses[index2].endNumES);
	return 0;
}

}
	return 1;//clean
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
int clashCounter;

courseNode*  insertNCheckCourse(char * course_id, Entry* student,creditCourse courses[], int num_courses){
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
		if(checkExamOverlap(course_id,temp->course_id,courses,num_courses) == 0){//print the roll wagera here
			printf("%d)Timetable Clash found for student %s (%s) in courses %s & %s\n", ++clashCounter, student->name,student->roll, course_id, temp->course_id);
		}
		temp=temp->next;
	}
	if(checkExamOverlap(course_id,temp->course_id,courses,num_courses) == 0){//print the roll wagera here
		printf("%d)Timetable Clash found for student %s (%s) in courses %s & %s\n", ++clashCounter, student->name,student->roll, course_id, temp->course_id);
	}
	// dprintf("\n");
	temp->next = newNode;
	return student->coursesHead;
}
// RATE DETERMINING STEP : 
void addEntries(char * course_id,char * filepath, Entry* entries[], int* num_entries,creditCourse courses[],int num_courses){
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
				entries[i]->coursesHead = insertNCheckCourse(course_id,entries[i],courses,num_courses);
				break;
			}
		}
		if(flag == 0){
			//new entry
			entries[*num_entries] = newEntry(roll,name,email);
			entries[*num_entries]->coursesHead = insertNCheckCourse(course_id,entries[*num_entries],courses,num_courses);
			*num_entries = *num_entries + 1;
		}
		fgetc(fp);
		fgetc(fp);
	}

	fclose(fp);
}
void openCourseFiles(char * directory,Entry* entries[], int* num_entries,creditCourse courses[],int num_courses){

	DIR *dp = NULL;
	struct dirent *dptr = NULL;
	char  course_id[SMALL_STR+5];
    // Open the directory stream
	char * filepath = concat(concat("course-wise-students-list/",directory),"/");
	// dprintf("%d)%s\n",*num_entries, filepath);
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
			if( strcmp(dptr->d_name,".") && strcmp(dptr->d_name,"..")){
		    // remove the .csv from filename
				strcpy(course_id,dptr->d_name);
				removeLast(course_id,4);
				// dprintf("%d) %s  %s\n", *num_entries, course_id, concat(filepath,dptr->d_name));
				addEntries(course_id, concat(filepath,dptr->d_name), entries,num_entries,courses, num_courses);
			}
		}
		closedir(dp);
	}
}

void processAllEntries(Entry* entries[], int* num_entries,creditCourse courses[],int num_courses){
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
				// dprintf(" Scraping directory [%s]   \n",dptr->d_name);
				openCourseFiles(dptr->d_name,entries,num_entries,courses, num_courses);
			}
		}
        // Close the directory stream
		closedir(dp);
	}

}

int main(){
	creditCourse courses[max_num_courses];
	int num_courses = 0;
	int i;
	loadCredits(courses, &num_courses);
	loadExamTimeTable(courses, &num_courses);
	// for ( i = 0; i < num_courses; ++i) dprintf("%s - %s - %d : %d-%d, %d-%d\n",courses[i].course_id, courses[i].exam_date,courses[i].credits, courses[i].startNumMS,courses[i].endNumMS,courses[i].startNumES,courses[i].endNumES);
	// printf("%d Courses loaded\n", num_courses);
	
	Entry* entries[max_num_entries];
	clashCounter = 0;
	int num_entries = 0;//initial
	processAllEntries(entries,&num_entries,courses, num_courses);
	// printf("%d students loaded \n", num_entries);
	courseNode* temp;
	int sum;
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
			printf("%d) Credits exceeded for student %s \t  (%s) : Total credits = %d \n", crcounter++, entries[i]->name,entries[i]->roll,sum);
		}
	}

	printf("Finished processing.    \n");
	return 0;
}