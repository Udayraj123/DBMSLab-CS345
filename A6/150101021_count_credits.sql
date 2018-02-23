use 150101021_23feb2018;

/*
Algorithm -
1. Join cwls and credits table
2. group by roll_number and calculate the credits sum 
3. Filter those having sum greater than max_credits
*/

DROP PROCEDURE if exists count_credits;
 
DELIMITER $$ ;
CREATE PROCEDURE count_credits ()
COMMENT 'Lists the student roll number, student name and total number of credits registered who have more than 40 credits'
  BEGIN
    set @max_credits = 40;

    SELECT roll_number, name,
           Sum(number_of_credits) AS total_credits
    FROM   cwls
           JOIN cc
             ON cwls.course_id = cc.course_id
    GROUP  BY roll_number,name
    HAVING total_credits > @max_credits
    ORDER  BY total_credits;
  END$$
DELIMITER ; $$

/*
ROUGH 
if have to use cursor, Single roll no query -
	set @roll = '176153102';
	select * from cwls where roll_number like @roll group by roll_number,course_id;
	select count(number_of_credits) from cc where course_id in (select course_id from cwls where roll_number like @roll group by roll_number,course_id);

SelfNotes: 
Viewing - SELECT NAME FROM MYSQL.PROC; or SHOW PROCEDURE STATUS;
Output variables are accessed using '@varname'

MySQL support for recursive procedures begins from version>=5.0, can also specify SET @@session.max_sp_recursion_depth = 255;

Procedures require the CREATE ROUTINE privilege

Using semicolon (;) as a delimiter causes problem in stored procedure because a procedure can have many statements,
	and every one of them must end with a semicolon. 

Performance - MySQL stored procedures are compiled on demand. After compiling a stored procedure, MySQL puts it into a cache of that mysql connection
*/