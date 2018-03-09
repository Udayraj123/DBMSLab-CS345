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

void flushFile(char *name){
	FILE* fp = fopen(name,"w");
	fprintf(fp, "%s", ""); // flush file
	fclose(fp);

}

void printCreditInserts(FILE* fp,FILE* fp_out,char* startline){
	fprintf(fp_out,"%s",startline);
	char course_id[SMALL_STR];
	int credits;
	fseek(fp,0,SEEK_SET);//reset to starting position
	fgetc(fp);
	while(!feof(fp)){
		fseek(fp,-1,SEEK_CUR);
		fscanf(fp,"%[^,],%d",course_id, &credits); 
		fgetc(fp);//capture ' '
		fgetc(fp);//capture \n
		fgetc(fp);//compensate fseek
		// printf("->%s<-%d\n", course_id, credits);
		fprintf(fp_out,"('%s',%d),\n",course_id,credits ); 
	}
	fseek(fp_out,-2,SEEK_CUR);//goto comma
	fprintf(fp_out,"%s",";\n");// replace comma with semicolon
}

void loadCredits(){
	FILE* fp = fopen("course-credits.csv","r");
	FILE* fp_out = fopen("150101021_cc.sql","w");
	printf("Adding Credits...\n");
	printCreditInserts(fp,fp_out,"INSERT INTO cc (course_id,number_of_credits) VALUES ");
	printCreditInserts(fp,fp_out,"INSERT INTO cc_temp (course_id,number_of_credits) VALUES ");
	printCreditInserts(fp,fp_out,"INSERT INTO cc_clone (course_id,number_of_credits) VALUES ");
	fclose(fp);
	fclose(fp_out);
}

void printETTInserts(FILE* fp,FILE* fp_out,char* startline){
	fprintf(fp_out,"%s",startline);

 // ('CE222','2018-02-25','09:00','11:00''CE222','2018-02-25','09:00','11:00')
	char course[SMALL_STR],start[SMALL_STR],end[SMALL_STR],exam_date[SMALL_STR];
	int  course_index,startNum,endNum;

	fseek(fp,0,SEEK_SET);//reset to starting position
	fgetc(fp);
	while(!feof(fp)){
		fseek(fp,-1,SEEK_CUR);
		// this da bug - there's a space at end!
		fscanf(fp,"%[^,],%[^,],%[^,],%[^\n ] ",course,exam_date,start,end);
		end[strlen(end)-1]='\0'; // to remove captured \n
		fgetc(fp);//compensate fseek
		fprintf(fp_out,"('%s','%s','%s','%s'),\n", course,exam_date,start,end);
	}
	fseek(fp_out,-2,SEEK_CUR);//goto comma
	fprintf(fp_out,"%s",";\n");// replace comma with semicolon
}
int loadExamTimeTable(){
	FILE* fp = fopen("exam-time-table.csv","r");
	FILE* fp_out = fopen("150101021_ett.sql","w");
	printf("Adding Timetables...\n");
	// As ETT has duplicates already, but the load should not stop
	printETTInserts(fp,fp_out,"INSERT IGNORE INTO ett (course_id,exam_date,start_time,end_time) VALUES ");
	printETTInserts(fp,fp_out,"INSERT IGNORE INTO ett_temp (course_id,exam_date,start_time,end_time) VALUES ");
	printETTInserts(fp,fp_out,"INSERT IGNORE INTO ett_clone (course_id,exam_date,start_time,end_time) VALUES ");
	fclose(fp);
	fclose(fp_out);
}

int strequal(char * s, char * s2){
	int n = strlen(s2) < strlen(s)? strlen(s2) : strlen(s);

	for (int i = 0; i < n; ++i)
	{
		if(s[i]!=s2[i])
			return 0;
	}
	return 1;
}

void printCWLSInserts(FILE* fp,FILE* fp_out,char* course_id,char* startline){
	fprintf(fp_out,"%s",startline);

	int i,serialno,flag;
	char roll[ROLL_LEN], name[MAX_STR_LEN], email[MAX_STR_LEN];

	fseek(fp,0,SEEK_SET);//reset to starting position
	fgetc(fp);//Files end with a newline, to consume it
	while(!feof(fp)){
		fseek(fp,-1,SEEK_CUR);
		strcpy(roll,"");
		fscanf(fp,"%d,%[^,],%[^,],%[^\n]",&serialno,roll, name,email);
		if(strcmp(roll,"")!=0){// skip last line
			email[strlen(email)]='\0';//remove captured '\n'
			fgetc(fp);//compensate fseek
			// printf(">>%s<<\n",email );
			fprintf(fp_out,"('%s','%s','%s','%s'),\n", course_id, roll, name,email);
		}
	}
	fseek(fp_out,-2,SEEK_CUR);//goto comma
	fprintf(fp_out,";\n");// replace comma with semicolon
}
void addEntries(char * course_id,char * filepath){
	FILE* fp = fopen(filepath,"r");
	/*
CAUTION : using Append mode makes fseek of no use for writing! It always writes at the end!!
 (though reading can be done at other pos, write resets the pointer to file end)
 TO OPEN FOR WRITING WITHOUT FLUSHING, USE "r+" mode, just the drawback of this is that the file must exist (in our case it is)

	*/
	// FILE* fp_out = fopen("150101021_cwls.sql","a");
	FILE* fp_out = fopen("150101021_cwls.sql","r+");
	fseek(fp_out,0,SEEK_END);
	// dprintf("scanning %s\n", course_id);
	printCWLSInserts(fp,fp_out,course_id,"INSERT INTO cwls (course_id, roll_number, name, email) VALUES ");
	printCWLSInserts(fp,fp_out,course_id,"INSERT INTO cwls_temp (course_id, roll_number, name, email) VALUES ");
	printCWLSInserts(fp,fp_out,course_id,"INSERT INTO cwls_clone (course_id, roll_number, name, email) VALUES ");
	fclose(fp);
	fclose(fp_out);
}
void openCourseFiles(char * directory){

	DIR *dp = NULL;
	struct dirent *dptr = NULL;
	char  course_id[SMALL_STR+5];
    // Open the directory stream
	char * filepath = concat(concat("course-wise-students-list/",directory),"/");
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
				addEntries(course_id, concat(filepath,dptr->d_name));
			}
		}
		closedir(dp);
	}
}

void processAllEntries(){
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
				openCourseFiles(dptr->d_name);
			}
		}
        // Close the directory stream
		closedir(dp);
	}

}

int main(){
	int i;
	printf("Started Processing\n");
	flushFile("150101021_cc.sql");
	flushFile("150101021_ett.sql");
	flushFile("150101021_cwls.sql");
	loadCredits();//1335 queries
	loadExamTimeTable();//2124 queries
	processAllEntries();//64788 queries
	printf("Finished Processing\n");
	return 0;
}
/*

system wc -l 150101021_cc.sql 150101021_cwls.sql 150101021_ett.sql 
   1335 150101021_cc.sql
   2124 150101021_ett.sql
  64788 150101021_cwls.sql
  68247 total

select count(*) from cwls;
+----------+
| count(*) |
+----------+
|    21119 | *3 = 63357
+----------+
^ THIS ONE HAS LESSER ENTRIES BECAUSE OF ENCODING ERROR- 
ERROR 1366 (HY000): Incorrect string value: '\xA0\xA0TULS...' for column 'name' at row 2

('ME513','174103120','MAHESH??TULSHIRAM??JUNGADE','mahes174103120'),
('ME522','174103078','VIJAY??BABURAO??SHAHAPURE','vijay174103078'),
('ME522','174103081','SAURABH??KUMAR??SINGH','saura174103081'),
('BT504','174106041','PAUSHALI??MUKHERJEE','paush174106041'),

Solution(Not working) - added this in create table - DEFAULT CHARACTER SET=utf8mb4;

After replacing the encoding -
  select count(*) from cwls;
+----------+
| count(*) |
+----------+
|    21596 | *3 = 64788 (matching)
+----------+
1 row in set (0.02 sec)

(ROUGH!)SELECT table_name, table_rows from information_schema.tables where table_name in ('cc','ett','cwls');
+------------+------------+
| table_name | table_rows |
+------------+------------+
| cc         |        445 | *3 = 1335
| cwls       |      20827 | *3 = ~63000
| ett        |        708 | *3 = 2124
+------------+------------+
Note : These counts will be a rough estimate of counts only according to mysql


*/

// -- SQL> INSERT INTO t(dob) VALUES(TO_DATE('17/12/2015', 'DD/MM/YYYY'));
