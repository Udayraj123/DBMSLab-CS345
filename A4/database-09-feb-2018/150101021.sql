create database if not exists 09feb2018;
	use 09feb2018;
-- The if not exists clauses allow to re-run this file during debugging

/*
CSV files-
They have different formats, hence they have to be manually rearranged to follow a standard format. 
Some of the depts have given in ScheduleIn format directly. Those cases need to be handled separately.
Strategy-
1. Converted all pdfs to xlsx (makes it easy to copy data)
2. Extract the tables containing schedules (remove extra clutters) and store it in a separate sheet.
3. Remove courses in lab slots
4. 
*/


-- SelfNote: Even for enum - MySQL will allow the value to be NULL if you do not specify NOT NULL 
/* Course table
course_code+division here will be primary key.
division has to be in - I,  II,  III,  IV,  NA, 'NA' being the case for dept level courses.
Semester of some courses are given in the pdfs, but ignored as not required here.
*/
create table Course (
	course_id int(3) auto increment not NULL comment "Added for convenience in setting up the ScheduledIn relation",
	course_code varchar(6) not NULL comment "varchar(6) used as course code can be at max 6 characters",
	division enum('I','II','III','IV','NA') not NULL comment "division has to be in - I,  II,  III,  IV,  NA, 'NA' being the case for dept level courses.",
	primary key (course_code,division),
	check(course_code regexp '^\w\w\d\d\dM?') -- checking for valid course code
);

/* Slot table
Lab Slots - AL1,etc are excluded and will not be allowed in this assignment.	
*/
create table Slot (
	slot_id int(2) auto increment not NULL comment "Added for convenience in setting up the ScheduledIn relation",
	letter enum('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'A1', 'B1', 'C1', 'D1', 'E1') not NULL comment "Given constraint added",
	day enum('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday') not NULL comment "Given constraint added",
	start_time TIME not NULL comment "As its format follows SQL TIME format, it is advantageous for e.g in comparing two time entries'",
	end_time TIME not NULL comment "As its format follows SQL TIME format, it is advantageous for e.g in comparing two time entries", 
	primary key (slot_id)
	-- primary key (letter,day) This one was also possible, but not needed as we added an id.
);

/* Room table
primary key(room_number) was not necessary, but added because it is given in the pdf.

*/
create table Room (
	room_number varchar(20) not NULL comment "Varchar seems best to support different formats of room numbers here (as they can contain letters too).",
	location enum('Core-I', 'Core-II', 'Core-III', 'Core-IV', 'LH', 'Local')  not NULL comment "Given constraint added",
	primary key (room_number)
);


/* Department table
department_id is taken from file names of the pdfs given.
enum not used for department_id to allow for new depts to be added in the future.
*/
create table Department (
	department_id varchar(10) not NULL comment "Although found max 9 letters(Institute), 10 is taken as a margin",
	name varchar(50) not NULL comment "varchar(50) is sufficient,an example long department name is Electronics and Electrical Engineering, which is 38 characters"
	primary key (department_id),
);

/* ScheduledIn table
This table should contain the relationship between Course, Department, Slot, Room
hence it should contain course_id, department_id, slot_id and room_number.

*/
create table ScheduledIn (
	
);
