drop database if exists 25jan2018;
create database if not exists 25jan2018 CHARACTER SET utf8mb4;
-- The if not exists clauses allow to re-run this file during debugging
use 25jan2018;

drop temporary table if exists cc_temp;
drop temporary table if exists ett_temp;
drop temporary table if exists cwls_temp;

/* ett table
No defaults required as there are no missing entries in exam-time-table.csv file
Not Null applies to all
No combination of columns is unique in this table, hence no primary or unique constraints
*/
create table ett (
course_id varchar(6) not NULL comment "varchar(6) because that is the maximum length of course-code. And for every exam, all the fields here are required to be non-empty, hence the not NULL",
exam_date DATE not NULL comment "used mysql DATE format as it fits the exam_date column and hence it will be managed efficiently in mysql. Also it can autocorrect some dates such as 29-02-2015 into 01-03-2015", 
-- Note:  '11:12' means '11:12:00', not '00:11:12 (format is HH:MM:SS)
-- Alternative without time :  start_time varchar(5) not NULL, check(start_time like '__:__'),
start_time TIME not NULL comment "As its format follows SQL TIME format, it is advantageous for e.g in comparing two time entries'",
end_time TIME not NULL comment "As its format follows SQL TIME format, it is advantageous for e.g in comparing two time entries", 
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
cid varchar(6) not NULL comment "Will store the course_id of the entry in cc table corresponding to a course.",
roll_number varchar(11) not NULL comment "Now there are roll_numbers with X as well, so we have to take them as strings",
name varchar(80) not NULL comment "80 is a marginal limit(For future entries) for length of student name ",
email varchar(50) default NULL comment "this one may be NULL as observed previously",
primary key(cid,roll_number), 
check(cid regexp '^\w\w\d\d\dM?'),-- checking for valid course code
check(roll_number regexp '^X?\d{9}')-- checking for valid roll number e.g. X170104081, 150101021
) DEFAULT CHARACTER SET utf8mb4;

-- step(i)-
create temporary table ett_temp (
course_id varchar(6) not NULL comment "varchar(6) because that is the maximum length of course-code. And for every exam, all the fields here are required to be non-empty, hence the not NULL",
exam_date DATE not NULL comment "used mysql DATE format as it fits the exam_date column and hence it will be managed efficiently in mysql. Also it can autocorrect some dates such as 29-02-2015 into 01-03-2015", 
start_time TIME not NULL comment "As its format follows SQL TIME format, it is advantageous for e.g in comparing two time entries'",
end_time TIME not NULL comment "As its format follows SQL TIME format, it is advantageous for e.g in comparing two time entries", 
check(course_id regexp '^\w\w\d\d\dM?')
) DEFAULT CHARACTER SET utf8mb4;
create temporary table cc_temp (
course_id varchar(6) primary key comment "as course code can be at max 6 characters, and it is unique and non-null throughout the table",
number_of_credits tinyint(1) not NULL comment "The tinyint range is sufficient (0-255)",
check(course_id regexp '^\w\w\d\d\dM?')-- checking for valid course code
) DEFAULT CHARACTER SET utf8mb4;

create temporary table cwls_temp (
cid varchar(6) not NULL comment "Will store the course_id of the entry in cc table corresponding to a course.",
roll_number varchar(11) not NULL comment "Now there are roll_numbers with X as well, so we have to take them as strings",
name varchar(80) not NULL comment "80 is a marginal limit(For future entries) for length of student name ",
email varchar(50) default NULL comment "this one may be NULL as observed previously",
primary key(cid,roll_number), 
check(cid regexp '^\w\w\d\d\dM?'),-- checking for valid course code
check(roll_number regexp '^X?\d{9}')-- checking for valid roll number e.g. X170104081, 150101021
) DEFAULT CHARACTER SET utf8mb4;

-- step(j)
create table cc_clone as select * from cc;
create table ett_clone as select * from ett;
create table cwls_clone as select * from cwls;

-- alternative : select * into cc_clone from cc;
-- CREATE TABLE AS is functionally similar to SELECT INTO. CREATE TABLE AS is the recommended syntax