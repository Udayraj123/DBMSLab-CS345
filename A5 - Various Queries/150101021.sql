use 09feb2018;
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
select course_id from ScheduledIn group by course_id having count(distinct room_number) > 1 order by course_id;
/*
| PH521     |
| PH531     |
| PH544     |
| PH545     |
+-----------+
32 rows in set (0.00 sec)
*/

-- (e) : 8 rows
select distinct(name) 
from Department 
where department_id in (select department_id from ScheduledIn where room_number in ('L2','L3','L1','L4'));
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
SET @totalSlots :=
  (SELECT count(*)
   FROM Slot);

SELECT department_id, count(DISTINCT slot_letter,slot_day) AS slotCount
FROM ScheduledIn
GROUP BY department_id
HAVING slotCount = @totalSlots;
/*
Empty set (0.00 sec)
Note: ME has maximum = 47 slots occupied. but not all
*/
-- checker: All Dept wise slotcounts:  select department_id,count(distinct slot_letter,slot_day) as slotCount from ScheduledIn group by department_id order by slotCount;

-- (h) : 55 rows
SELECT slot_letter,
slot_day,
count(DISTINCT course_id,course_division) AS courseCount
FROM ScheduledIn
GROUP BY slot_letter,
slot_day
ORDER BY courseCount;
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
SELECT room_number,
count(DISTINCT course_id,course_division) AS courseCount
FROM ScheduledIn
GROUP BY room_number
ORDER BY courseCount;
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
DROP TABLE IF EXISTS allassigned;
CREATE
TEMPORARY TABLE allassigned AS
(SELECT slot_letter, count(DISTINCT course_id,course_division) AS courseCount
	FROM ScheduledIn
	GROUP BY slot_letter
	ORDER BY courseCount);

SET @min :=
(SELECT min(courseCount)
	FROM allassigned);

SELECT slot_letter,
courseCount
FROM allassigned
WHERE courseCount = @min;
/*
+-------------+-------------+
| slot_letter | courseCount |
+-------------+-------------+
| I           |           2 |
+-------------+-------------+
1 row in set (0.00 sec)
*/ 
-- (k) : 10 rows
SELECT DISTINCT course_id AS Minor,
GROUP_CONCAT(slot_day,"-",slot_letter) AS assignedSlots
FROM ScheduledIn
WHERE course_id LIKE '_____M'
GROUP BY course_id;
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
DROP TABLE IF EXISTS dept_slots;

CREATE
TEMPORARY TABLE dept_slots
SELECT DISTINCT department_id, slot_day, slot_letter
FROM ScheduledIn;
-- Without group_concat-
SELECT department_id, DAY, letter
FROM Slot,
Department
WHERE (department_id, DAY, letter) NOT IN
(SELECT * FROM dept_slots)
ORDER BY department_id,
DAY,
letter;
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
 SELECT department_id, group_concat(substr(DAY,1,3),letter) AS unusedSlots
 FROM Slot,
 Department
 WHERE (department_id, DAY, letter) NOT IN
 (SELECT * FROM dept_slots)
 GROUP BY department_id
 ORDER BY unusedSlots;
/*
| EE            | TueJ,WedK,FriB1,ThuI,TueL,WedD1,ThuC1,TueE1,MonK,MonA1,TueI,FriK,ThuJ,ThuL                                                                                                                                                                                                                        |
| CH            | WedK,FriG,MonF,ThuI,TueE,MonG,MonA1,WedF,TueH,TueI,MonK,FriK,WedG,ThuJ,FriF,TueJ,ThuH                                                                                                                                                                                                             |
--------------------------------------------------------------------------------------------------------
13 rows in set (0.01 sec)
*/ 
-- Even prettier:
SELECT department_id,
group_concat(letter,concat('(',substr(DAY,1,if(DAY LIKE 'T%',2,1)),')')) AS unusedSlots
FROM Slot,
Department
WHERE (department_id, DAY, letter) NOT IN
(SELECT * FROM dept_slots)
GROUP BY department_id
ORDER BY unusedSlots;
/*
| EE            | K(M),B1(F),J(Th),D1(W),A1(M),L(Th),I(Tu),K(F),I(Th),L(Tu),C1(Th),E1(Tu),J(Tu),K(W)                                                                                                                                                                                                                                       |
| ME            | L(Th),I(Tu),I(Th),L(Tu),K(F),J(Tu),K(W),E1(F),K(M),J(Th)                                                                                                                                                                                                                                                                 |
+---------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
13 rows in set (0.01 sec)
*/ 
-- ROUGH:
-- JOIN -  select * from Course c join ScheduledIn s on c.course_id = s.course_id and c.division = s.course_division;