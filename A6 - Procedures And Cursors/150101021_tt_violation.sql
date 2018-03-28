use 150101021_23feb2018;

/*
Rough SelfNotes: PREGENERATE IN TEMP TABLE -
There are 329 course_id entries in ett. => 329C2 =  53956 pregenerated pairs with a yes/no column stating their overlap
	Generating them in order will save calculations
	But as there arre ~4000 students each with avg 6C2=15 pairs = 60000 pairs, thus it has more calculations and it is unordered as well.

Also, it is better to loop cursor on each course and list out the roll numbers in it, 
and it will be easier to use two pointers in it.
We can make use of lexical order

Final Algo-
for each course course1:
	for each course course2 ahead of course1: (declare cursor inside of the loop)
		if(checkOverlap(course1,course2))
			load roll_number,name in the courses course1 and course2 and print the clash lines 

*/

DROP PROCEDURE if exists tt_violation;
DROP PROCEDURE if exists check_overlap;
DELIMITER $$ ;

create procedure check_overlap (in course1 varchar(6),in course2 varchar(6), out overLapCount tinyint(1))
COMMENT 'function to check for clashing timetable of two courses'
	begin
	-- Complexity : O(size(ett)^2) (unless SQL optimizes internally which would further reduce it)
	-- possible values of output overLapCount : 
	-- 		0 (no clash), 1(if one of ES/MS clashes), 2 (if both clashes)
		SELECT count(*) INTO overLapCount
		FROM
		  (SELECT *
		   FROM ett
		   WHERE course_id LIKE course1) a -- MS and ES tt of course1
		JOIN
		  (SELECT *
		   FROM ett
		   WHERE course_id LIKE course2) b -- MS and ES tt of course1
	  	ON a.exam_date = b.exam_date
		AND a.start_time < b.end_time
		AND b.start_time < a.end_time;
	end$$


create procedure tt_violation ()
COMMENT 'Lists the student roll number, student name and the two courses_id’s having exam time table clash'
	begin
	-- *complexity without internal optimization = size(ett)*size(ett)* ( size(ett)^2 + size(cwls) )??
		declare course1,course2 varchar(6);
		declare outer_finished,inner_finished,overLapCount tinyint(1) default 0;
		declare pairNumber int(4) default 1;
		declare validCount,clashCounter int(4) default 0;
		declare cur1 cursor for select course_id from ett group by course_id order by course_id
		;-- limit 50;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET outer_finished = 1;
	    open cur1;

    	
    	drop table if exists output;
    	create temporary table output (clashCounter int(4), roll_number varchar(11), name varchar(80), course1 varchar(6), course2 varchar(6),Overlap varchar(30));

    	set outer_finished = 0; -- Good habit (imagine this routine being rerun again without this var).
	    outer_loop: loop
	        fetch cur1 into course1;
	        if outer_finished = 1 then
	        	leave outer_loop;
	        end if;

		    outer_block: begin
				declare cur2 cursor for select course_id from ett group by course_id having course_id > course1 order by course_id
				 ;-- limit 50;
		        DECLARE CONTINUE HANDLER FOR NOT FOUND SET inner_finished = 1;
			    open cur2;
	        	
	        	set inner_finished = 0; -- to be continuing into next loop
			    inner_loop: loop
				    inner_block: Begin 
				        fetch cur2 into course2;
				        if inner_finished = 1 then
				        	leave inner_loop;
				        end if;
				        select pairNumber+1 into pairNumber;-- alter to set pairNumber = pairNumber+1

			        	call check_overlap(course1,course2,overLapCount);
				        	if overLapCount > 0 then 
					        	-- Now, List students enrolled in both courses

					        	 -- Nope: Method1(extensible easily) - groupBy and count :  Less eff
					        	 -- select IF(overLapCount = 1,"Either MS or ES","Both ES and MS") as Overlap,roll_number,name,course1,course2 from cwls where roll_number in (select roll_number from cwls where course_id like course1 or course_id like course2 group by roll_number having count(*)>1) group by roll_number,name;
					        	 
					        	 -- Yup: Method2 -INTERSECT USING 'IN' :  size(cwls)^2 (but a course can't have all students, hence this is much closer to size(cwls))
						        	select count(roll_number) into validCount from cwls where course_id like course1 and roll_number in (select roll_number from cwls where course_id like course2);
						        	if validCount > 0 then
								        select clashCounter+validCount into clashCounter;
							        	insert into output select clashCounter,roll_number,name,course1,course2,IF(overLapCount = 1,"Either of MS or ES","Both ES and MS clash") as Overlap
							        	 from cwls where course_id like course1 and roll_number in (select roll_number from cwls where course_id like course2);
						        	end if;
				        	end if;
				    end inner_block;
			    end loop inner_loop;
			    close cur2;
		    end outer_block;
	    end loop outer_loop;
	    select * from output;
	    close cur1;
	end$$
DELIMITER ; $$



select "Calling procedure: tt_violation" as 'CURRENT ACTION:';
CALL tt_violation(); -- do it from terminal


/*
Rough - 
		        -- if array type needed-  SET email_list = CONCAT(v_email,";",email_list)

Marking - 
_/	correct variable declaration: 1
_/	cursor declaration and correct select statement: 1 + 2
_/	correct usage of loop: 1
??	error handling: 1
_/	correct usage of conditional statements: 1
_/	correct output: 3

Nope- Bruteforce -
1. Use cursor to iterate through students table and another for ett table
2. for each student : 
		load their course list from cwls
		for each pair of courses list:
			call checkForOverlap(course1,course2) which will print if clash exists.

*/