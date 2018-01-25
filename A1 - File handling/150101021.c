#include <stdio.h>
#define ll long int

int strequal(char * s, char * s2, int n){
	for (int i = 0; i < n; ++i)
	{
		if(s[i]!=s2[i])
			return 0;
	}
	return 1;
}

typedef struct entry
{
int roll, present;
char class_date[11];
} Entry;

int hashRoll(int roll, int min_roll){
	return roll - min_roll;
}

void flushFile(char *name){
	FILE* fp = fopen(name,"w");
	fprintf(fp, "%s", ""); // flush file
	fclose(fp);

}

/*
Assumptions 
- Entries are ordered by roll numbers (descending)
- Duplicates are not present
- batch strength and number of days are fixed. (read from file)
- The sheet contains attendance for each student for each distinct day. 
  For missing entries, it will be assumed the student was not present.
- Date follows a strict format having length = 10
- Status has only two values "Present"/"Absent"

Done - Now, load the batch_strength and num_days from file itself.

	*/
void loadBatchNDays(ll *a, int *b, int *c){
	FILE* fp = fopen("database_12jan2017.csv","r");
	ll prev_roll = -1,roll;//9 digits
	ll  min_roll = 999999999;// = 780102959;
	char class_date[11],status[10];
	int batch_strength,num_days;// = 41,= 32;
	int days = 0,counter=1;
	batch_strength = 1;
	// since we already assume order, no need of arrays to count distinct rolls.
	while(!feof(fp)){
	// Note - %s consumes the ',' as well! use %[^,]
		fscanf(fp,"%ld, %[^,], %s",&roll,class_date,status);
		// printf("%d) %d, %s, %s\n",counter++,roll,class_date,status);
		min_roll = min_roll > roll ? roll : min_roll;
		days++;
		if(prev_roll != -1 && roll != prev_roll){
			batch_strength++;
			// if(days!=0 && num_days!=days)
			// 	printf(" No of days are inconsistent per student : %d, %d, rolls = %ld %ld \n", num_days, days, roll, prev_roll);
			num_days = days;
			days = 0;
		}
		prev_roll = roll;
	}
	fclose(fp);
	*a = min_roll;
	*b = batch_strength;
	*c = num_days;
}

/*
This program can process a file with any number of students, with attendance of any number of days. 
Only requirement is that the roll numbers are in descending order and 
 each roll number has same no of entries as number of days.

*/

int main(){
	ll roll,min_roll = 999999999;
	char class_date[11],status[10];
	FILE * fp;
	int batch_strength,num_days,counter;// = 41,= 32;
	// run on file once to determine these three
	loadBatchNDays(&min_roll,&batch_strength, &num_days);
	
	// printf("%ld , %d , %d \n", min_roll, batch_strength, num_days);  return 0;
	
	int num_entries  = batch_strength * num_days;
	Entry entries[num_entries];
	Entry t; 

	int id= 0, day = 0;
	fp = fopen("database_12jan2017.csv","r");
	while(!feof(fp))
	{
		fscanf(fp,"%ld, %[^,], %s",&roll,t.class_date,status);
		// printf("%d) %d, %s, %s\n",counter++,roll,t.class_date,status);
		t.roll = hashRoll(roll,min_roll);
		t.present = strequal(status,"Present", 8);
		day++;
		entries[id++] = t;
		if(day == num_days)
			day = 0;
	}
	fclose(fp);
	
	// Start with output files
	flushFile("G75.csv");
	flushFile("L75.csv");
	FILE * fpG = fopen("G75.csv","a");
	FILE * fpL = fopen("L75.csv","a");

	int present_count=0,max_roll = min_roll + batch_strength;
	float percentage; // derived attribute
	for (int i = 1; i <= num_entries; ++i)
	{
		
		present_count += entries[i-1].present;

		// printf("%d) %d \n", i, present_count);
		if(i%num_days==0){
			//store and reset
			fp = (present_count*4 >= num_days*3)? fpG : fpL;
			fprintf(fp, "%d, %d, %2f\n", max_roll - i/num_days , present_count, 100 * (float)present_count/(float)num_days );
			present_count = 0;
		}
	}
	fclose(fp);
	printf("Finished processing. Output files - G75.csv and L75.csv are generated.\n");
	return 0;
}