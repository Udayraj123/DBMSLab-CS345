create database 25jan2018;
use 25jan2018;


/*
No defaults required as there are no missing entries in exam-time-table.csv file
Not Null applies to all
*/
create table ett (
course_id varchar(6) not NULL,
exam_date DATE not NULL, 
start_time TIME not NULL comment "Its format is HH:MM:SS and '11:12' means '11:12:00', not '00:11:12'",
end_time TIME not NULL comment "Its format is HH:MM:SS and '11:12' means '11:12:00', not '00:11:12'", 
-- Alternative start_time varchar(5) not NULL, check(start_time like '__:__'),
check(course_id regexp '^\w\w\d\d\dM?'),
)
-- SQL> INSERT INTO t(dob) VALUES(TO_DATE('17/12/2015', 'DD/MM/YYYY'));


create table cc (
course_id varchar(6) not NULL,
number_of_credits tinyint(1) not NULL; -- range is sufficient 0-255
check(course_id regexp '^\w\w\d\d\dM?'),
)
-- Each entry of this table will describe a student-to-course relation 'Credits'
create table cwls (
-- Cannot put serial_number as it is reset accross files
cid int not NULL, -- Will store the id of the entry in cc table corresponding to a course
roll_number varchar(11) not NULL, -- Now there are rollnos with X as well, so we have to take them as strings
name varchar(80) not NULL, -- 80 is a marginal limit for length of student's name
email varchar(50), -- this one can be NULL as observed
)