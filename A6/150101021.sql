-- THIS FILE IS NOT TO BE SUBMITTED, use mysqldump for final submission
drop database if exists 150101021_23feb2018;
create database 150101021_23feb2018 CHARACTER SET utf8mb4;
-- The if not exists clauses allow to re-run this file during debugging
use 150101021_23feb2018;

/* ett table
No defaults required as there are no missing entries in exam-time-table.csv file
Not Null applies to all
Nope, add primary key of the columns,some duplicates will occur otherwise! - No combination of columns is unique in this table, hence no primary or unique constraints
*/
create table ett (
-- line number attribute and associated data are not present in the exam-time-table.csv file. You have to create this schema and insert the line number data.
line_number int(5) auto_increment not NULL comment "unique serial number of the exam-time-table entry",
index(line_number), -- another way to tell it is a KEY
course_id varchar(6) not NULL comment "varchar(6) because that is the maximum length of course-code. And for every exam, all the fields here are required to be non-empty, hence the not NULL",
exam_date DATE not NULL comment "used mysql DATE format as it fits the exam_date column and hence it will be managed efficiently in mysql. Also it can autocorrect some dates such as 29-02-2015 into 01-03-2015", 
-- SelfNote:  '11:12' means '11:12:00', not '00:11:12 (format is HH:MM:SS)
-- Alternative without time :  start_time varchar(5) not NULL, check(start_time like '__:__'),
start_time TIME not NULL comment "As its format follows SQL TIME format, it is advantageous for e.g in comparing two time entries'",
end_time TIME not NULL comment "As its format follows SQL TIME format, it is advantageous for e.g in comparing two time entries", 
primary key(course_id,exam_date,start_time,end_time),
check(course_id regexp '^\w\w\d\d\dM?')
-- This charset is required to accept \xa0 character in given csv file (see bottom of .c file for more details)
) DEFAULT CHARACTER SET utf8mb4;

/* cc table
course_id here will be primary key.
*/
create table cc (
course_id varchar(6) primary key comment "as course code can be at max 6 characters, and it is unique and non-null throughout the table",
number_of_credits tinyint(1) not NULL comment "The tinyint range is sufficient (0-255)",
check(course_id regexp '^\w\w\d\d\dM?')-- checking for valid course code
) DEFAULT CHARACTER SET utf8mb4;

/* cwls table
Each entry of cwls table will describe a student-to-course relation 'Credits'

As the student-course combination should be unique, that has to be the primary key
*/ 
create table cwls (
-- Cannot put serial_number in columns as it is reset accross files
course_id varchar(6) not NULL comment "Will store the course_id of the entry in cc table corresponding to a course.",
roll_number varchar(11) not NULL comment "Now there are roll_numbers with X as well, so we have to take them as strings",
name varchar(80) not NULL comment "80 is a marginal limit(For future entries) for length of student name ",
email varchar(50) default NULL comment "this one may be NULL as observed previously",
primary key(course_id,roll_number), 
check(course_id regexp '^\w\w\d\d\dM?'),-- checking for valid course code
check(roll_number regexp '^X?\d{9}')-- checking for valid roll number e.g. X170104081, 150101021
) DEFAULT CHARACTER SET utf8mb4;

/*
Good discussion- https://stackoverflow.com/questions/548541/insert-ignore-vs-insert-on-duplicate-key-update
*/
-- REPLACE THESE IN FINAL SUBMISSION, put source loadAll-
SELECT table_name, table_rows from information_schema.tables where table_name in ('cc','ett','cwls');

insert into ett (course_id,exam_date,start_time,end_time) select (course_id,exam_date,start_time,end_time) from 25jan2018.ett as b ON DUPLICATE KEY UPDATE course_id=b.course_id;
-- 657 unique rows out of 708 total (rest 51 are insert errors coz of primary key constraints)

insert into cc (course_id,number_of_credits) select (course_id,number_of_credits) from 25jan2018.cc as b ON DUPLICATE KEY UPDATE course_id=b.course_id;
-- 445 unique rows

insert into cwls (course_id,roll_number,name,email) select (course_id,roll_number,name,email) from 25jan2018.cwls as b ON DUPLICATE KEY UPDATE course_id=b.course_id;
-- 21596 unique rows