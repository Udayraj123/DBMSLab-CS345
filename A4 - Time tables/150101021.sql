drop database if exists 09feb2018;
create database 09feb2018;
	use 09feb2018;
-- The if not exists clauses allow to re-run this file during debugging
-- SelfNote: Even for enum - MySQL will allow the value to be NULL if you do not specify NOT NULL 
/* Course table
course_id+division here will be primary key.
division has to be in - I,  II,  III,  IV,  NA, 'NA' being the case for dept level courses.
Semester of some courses are given in the pdfs, but ignored as not required here.
*/
create table Course (
	-- course_id int(3) auto increment not NULL comment "Added for convenience in setting up the ScheduledIn relation",
	course_id varchar(6) not NULL comment "varchar(6) used as course code can be at max 6 characters",
	division enum('I','II','III','IV','NA') not NULL comment "division has to be in - I,  II,  III,  IV,  NA, 'NA' being the case for dept level courses.",
	primary key (course_id,division),
	check(course_id regexp '^\w\w\d\d\dM?') -- checking for valid course code
);

/* Slot table
Lab Slots - AL1,etc are excluded and will not be allowed in this assignment.	
*/
create table Slot (
	-- slot_id int(2) auto increment not NULL comment "Added for convenience in setting up the ScheduledIn relation",
	-- primary key (slot_id),
	letter enum('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'A1', 'B1', 'C1', 'D1', 'E1') not NULL comment "Given constraint added",
	day enum('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday') not NULL comment "Given constraint added",
	start_time TIME not NULL comment "As its format follows SQL TIME format, it is advantageous for e.g in comparing two time entries'",
	end_time TIME not NULL comment "As its format follows SQL TIME format, it is advantageous for e.g in comparing two time entries", 
	primary key(letter,day) -- letter_day is the unique_index
	-- unique key letter_day(letter,day) -- letter_day is the unique_index
);

/* Room table
primary key(room_number) was not necessary, but added because it is given in the pdf.

*/
create table Room (
	room_number varchar(15) not NULL comment "Varchar seems best to support different formats of room numbers here (as they can contain letters too).",
	location enum('Core-I', 'Core-II', 'Core-III', 'Core-IV', 'LH', 'Local')  not NULL comment "Given constraint added",
	primary key (room_number)
);


/* Department table
department_id is taken from file names of the pdfs given.
enum not used for department_id to allow for new depts to be added in the future.
*/
create table Department (
	department_id varchar(5) not NULL comment "Although found max 2 letters, 5 is taken as a margin",
	name varchar(60) not NULL comment "varchar(60) is sufficient,for longest department name is Electronics and Electrical Engineering, which takes 52 bytes",
	primary key (department_id)
);

/* ScheduledIn table
This table should contain the relationship between Course, Department, Slot, Room
hence it should contain atleast course_id, department_id, slot_id and room_number.

SelfNote: 
	Foreign key (slot_letter,slot_day) references 09feb2018.Slot(letter,day)
	(not an issue in this asgn) -> But this may cause problem in adding NULL entries, more general & reliable way is to use the extra id column in slots
	Good ans - https://stackoverflow.com/questions/3178709/foreign-key-referencing-a-2-columns-primary-key-in-sql-server
.
.
*/
create table ScheduledIn (
	course_id varchar(6) not NULL comment "Relational Reference to respective table",
	course_division enum('I','II','III','IV','NA') not NULL comment "Relational Reference to respective table",
	slot_letter enum('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'A1', 'B1', 'C1', 'D1', 'E1') not NULL comment "Relational Reference to respective table",
	slot_day enum('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday') not NULL comment "Relational Reference to respective table",
	department_id varchar(10) not NULL comment "Relational Reference to respective table",
	room_number varchar(15) not NULL comment "Relational Reference to respective table",
	primary key (course_id,course_division, department_id, slot_letter,slot_day ,room_number),
	Foreign key (department_id) references 09feb2018.Department(department_id),
	Foreign key (room_number) references 09feb2018.Room(room_number),
	Foreign key (slot_letter,slot_day) references 09feb2018.Slot(letter,day),
	Foreign key (course_id,course_division) references 09feb2018.Course(course_id,division),
	check(course_id regexp '^\w\w\d\d\dM?')
);
