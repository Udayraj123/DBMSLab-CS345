use 25jan2018;

/*
M2) PREGENERATE IN TEMP TABLE -
There are 329 course_id entries in ett. => 329C2 =  53956 pregenerated pairs with a yes/no column stating their overlap
	Generating them in order will save calculations
	But as there arre ~4000 students each with avg 6C2=15 pairs = 60000 pairs, thus it has more calculations and it is unordered as well.

Also, it is better to loop cursor on each course and list out the roll numbers in it, 
and it will be easier to use two pointers in it.
We can make use of lexical order

1. Create temp table (outside or inside?) ett_clash
2. for each course course1:
	for each course course2 ahead of course1: (declare cursor inside of the loop)
		if(checkOverlap(course1,course2))
			load roll_number,name in the courses course1 and course2 and print the clash lines 

Bruteforce -
1. Use cursor to iterate through students table and another for ett table
2. for each student : 
		load their course list from cwls
		for each pair of courses list:
			call checkForOverlap(course1,course2) which will print if clash exists
.
*/

DROP PROCEDURE if exists tt_violation;
DELIMITER $$ ;
/*
create procedure check_overlap (in course1 varchar(6),in course2 varchar(6), out overLapCount tinyint(1))
COMMENT 'function to check for clashing timetable of two courses'
	begin
	-- Complexity : size(ett)^2
	-- possible values of overLapCount :  0 (no clash), 2(if one of ES/MS clashes), 4 (if both clashes)
		 -- select count(*) into @overLapCount from  (select * from ett where course_id like @course1) a  join  (select * from ett where course_id like @course2) b on a.exam_date = b.exam_date and a.start_time < b.end_time and b.start_time < a.end_time;
		SELECT count(*) INTO overLapCount
		FROM
		  (SELECT *
		   FROM ett
		   WHERE course_id LIKE course1) a
		JOIN
		  (SELECT *
		   FROM ett
		   WHERE course_id LIKE course2) b ON a.exam_date = b.exam_date
		AND a.start_time < b.end_time
		AND b.start_time < a.end_time;
	end$$
*/

create procedure tt_violation ()
COMMENT 'Lists the student roll number, student name and the two courses_id’s having exam time table clash'
	begin
	-- complexity = size(ett)*size(ett)* ( size(ett)^2 + size(cwls) )
		declare course1,course2 varchar(6);
		declare cur1 cursor for select course_id from ett group by course_id order by course_id;
	    open cur1;
	    outer_loop: loop
        fetch cur1 into course1;
        -- DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
        --  SET email_list = CONCAT(v_email,";",email_list)
		declare cur2 cursor for select course_id from ett group by course_id  having course_id > course1 order by course_id;
	    open cur2;
	    inner_loop:
        fetch cur2 into course2;
        select @course1,@course2;
        /*
        	call check_overlap(@course1,@course2);
        	if @overLapCount > 0 then 
        	-- students enrolled in both courses
        	 -- Method1(extensible easily) - groupBy and count :  
        	 -- select IF(@overLapCount = 2,"Both ES and MS","Either MS or ES") as Overlap,roll_number,name,@course1,@course2 from cwls where roll_number in (select roll_number from cwls where cid like @course1 or cid like @course2 group by roll_number having count(*)>1) group by roll_number,name;
        	 select IF(@overLapCount = 2,"Both ES and MS","Either MS or ES") as Overlap,roll_number,name,course1,course2 from cwls where roll_number in (select roll_number from cwls where cid like course1 or cid like course2 group by roll_number having count(*)>1) group by roll_number,name;
        	 -- Method2 - intersect :  select roll_number from cwls where course_id like course1 and roll_number in (select roll_number from cwls where course_id like course2);
        	else

        	end if;*/
	    end loop inner_loop
	    close cur2;
	    end loop outer_loop
	    close cur1;
	end$$
DELIMITER ; $$

-- CALL tt_violation();


/*
Rough - 
Marking - 
	correct variable declaration: 1
	cursor declaration and correct select statement: 1 + 2
	correct usage of loop: 1
	error handling: 1
	correct usage of conditional statements: 1
	correct output: 3

*/