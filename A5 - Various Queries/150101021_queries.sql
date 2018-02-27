/*
Assumptions - The more natural meanings are taken for following terms
1. "slots" means slot_letter + slot_day (not just slot_letter)
2. "courses" means course_id only (and not course_id + division)
3. DD is completely removed from DB (Departments table will not have Design Department in it as it affects the answer of queries below)

*/


-- (a) : 5 rows
select distinct(course_id) from ScheduledIn where room_number='2001';
/*
+-----------+
| course_id |
+-----------+
| CS501     |
| CS503     |
| CS525     |
| CS561     |
| CS666     |
+-----------+
5 rows in set (0.00 sec)
*/



-- (b) : 56 rows
select distinct(course_id) from ScheduledIn where slot_letter='C';
/*
| ME619     |
| PH206     |
| PH527     |
| EE270     |
| EE551     |
| HS623     |
+-----------+
56 rows in set (0.00 sec)
*/


-- (c) : 4 rows
select distinct(course_division) from ScheduledIn where room_number in ('L2','L3');
/*
+-----------------+
| course_division |
+-----------------+
| I               |
| III             |
| II              |
| IV              |
+-----------------+
4 rows in set (0.00 sec)
*/



-- (d) : 32 rows
select course_id from ScheduledIn group by course_id having count(distinct room_number) > 1;
/*
| PH102     |
| PH521     |
| PH531     |
| PH544     |
| PH545     |
+-----------+
32 rows in set (0.00 sec)
*/


-- (e) : 8 rows
select distinct(name) from Department where department_id in (select department_id from ScheduledIn where room_number in ('L2','L3','L1','L4'));
/*
+------------------------------------------------------+
| name                                                 |
+------------------------------------------------------+
| Department Of Biosciences and Bioengineering         |
| Department of Computer Science and Engineering       |
| Department of Electronics and Electrical Engineering |
| Center for Energy                                    |
| Department Of Humanities and Social Sciences         |
| Department Of Mathematics and Computing              |
| Department Of Mechanical Engineering                 |
| Department Of Physics                                |
+------------------------------------------------------+
8 rows in set (0.00 sec)
*/


-- (f) : 5 rows
select distinct(name) from Department where department_id not in (select department_id from ScheduledIn where room_number in ('L2','L1'));
/*
+------------------------------------------------+
| name                                           |
+------------------------------------------------+
| Department of Civil Engineering                |
| Department Of Chemical Sciences and Technology |
| Department Of Chemical Engineering             |
| Centre for Linguistic Science and Technology   |
| Centre for Rural Technology                    |
+------------------------------------------------+
5 rows in set (0.00 sec)
*/


-- (g) : 0 rows
set @totalSlots := (select count(*) from Slot);
select department_id,count(distinct slot_letter,slot_day) as slotCount from ScheduledIn group by department_id having slotCount = @totalSlots;
/*
Empty set (0.00 sec)

Note: ME has maximum = 47 slots occupied. but not all
*/
-- checker: All Dept wise slotcounts:  select department_id,count(distinct slot_letter,slot_day) as slotCount from ScheduledIn group by department_id order by slotCount;



-- (h) : 55 rows
select slot_letter,slot_day,count(distinct course_id,course_division) as courseCount from ScheduledIn group by slot_letter,slot_day order by courseCount;
/*
| C           | Monday    |          35 |
| A           | Thursday  |          36 |
| A           | Wednesday |          37 |
| C           | Tuesday   |          38 |
| A           | Tuesday   |          41 |
+-------------+-----------+-------------+
55 rows in set (0.01 sec)
*/



-- (i) : 55 rows
select room_number,count(distinct course_id,course_division) as courseCount from ScheduledIn group by room_number order by courseCount;
/*
| 1002          |          11 |
| 4208          |          11 |
| 4201          |          11 |
| 3102          |          12 |
| 1003          |          13 |
| 1005          |          13 |
| 4004          |          14 |
+---------------+-------------+
55 rows in set (0.01 sec)
*/


-- (j) : 1 rows
drop table if exists allassigned;
create temporary table allassigned as (select slot_letter,count(distinct course_id,course_division) as courseCount from ScheduledIn group by slot_letter order by courseCount);
set @min := (select min(courseCount) from allassigned);
select slot_letter,courseCount from allassigned where courseCount = @min;	
/*
+-------------+-------------+
| slot_letter | courseCount |
+-------------+-------------+
| I           |           2 |
+-------------+-------------+
1 row in set (0.00 sec)
*/


-- (k) : 10 rows
select distinct course_id as Minor,GROUP_CONCAT(slot_day,"-",slot_letter) as assignedSlots from ScheduledIn where course_id like '_____M' group by course_id;
/*
+--------+-------------------------------+
| Minor  | assignedSlots                 |
+--------+-------------------------------+
| CL252M | Monday-F,Wednesday-F,Friday-F |
| CL352M | Monday-G,Wednesday-G,Friday-G |
| CS206M | Monday-F,Wednesday-F,Friday-F |
| CS350M | Monday-G,Wednesday-G,Friday-G |
| EE213M | Monday-F,Wednesday-F,Friday-F |
| EE322M | Monday-G,Wednesday-G,Friday-G |
| MA212M | Monday-F,Wednesday-F,Friday-F |
| MA312M | Monday-G,Wednesday-G,Friday-G |
| ME321M | Monday-G,Wednesday-G,Friday-G |
| PH382M | Monday-G,Wednesday-G,Friday-G |
+--------+-------------------------------+
10 rows in set (0.00 sec)
*/


-- (l) : 322 rows (without DD)
drop table if exists dept_slots;
create temporary table dept_slots select distinct department_id,slot_day,slot_letter from ScheduledIn;
-- Without group_concat-
select department_id,day,letter from Slot,Department where (department_id,day,letter) not in (select * from dept_slots) order by department_id,day,letter;
/*
| RT            | Friday    | K      |
| RT            | Friday    | B1     |
| RT            | Friday    | C1     |
| RT            | Friday    | D1     |
| RT            | Friday    | E1     |
+---------------+-----------+--------+
322 rows in set (0.01 sec)
*/


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- ALTERNATIVES for (l) -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

-- group_concat Gives a one-page view for the same:
select department_id,group_concat(substr(day,1,3),letter) as unusedSlots from Slot,Department where (department_id,day,letter) not in (select * from dept_slots) group by department_id order by unusedSlots;
/*
| EE            | TueJ,WedK,FriB1,ThuI,TueL,WedD1,ThuC1,TueE1,MonK,MonA1,TueI,FriK,ThuJ,ThuL                                                                                                                                                                                                                        |
| CH            | WedK,FriG,MonF,ThuI,TueE,MonG,MonA1,WedF,TueH,TueI,MonK,FriK,WedG,ThuJ,FriF,TueJ,ThuH                                                                                                                                                                                                             |
--------------------------------------------------------------------------------------------------------
13 rows in set (0.01 sec)
*/
-- Even prettier: 
select department_id,group_concat(letter,concat('(',substr(day,1,if(day like 'T%',2,1)),')')) as unusedSlots from Slot,Department where (department_id,day,letter) not in (select * from dept_slots) group by department_id order by unusedSlots;
/*
| EE            | K(M),B1(F),J(Th),D1(W),A1(M),L(Th),I(Tu),K(F),I(Th),L(Tu),C1(Th),E1(Tu),J(Tu),K(W)                                                                                                                                                                                                                                       |
| ME            | L(Th),I(Tu),I(Th),L(Tu),K(F),J(Tu),K(W),E1(F),K(M),J(Th)                                                                                                                                                                                                                                                                 |
+---------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
13 rows in set (0.01 sec)

*/
-- ROUGH: 
-- JOIN -  select * from Course c join ScheduledIn s on c.course_id = s.course_id and c.division = s.course_division;