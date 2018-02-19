/*
Ask - 
"slots" means slot_letter only ??
"courses" means course_id or course_id + division ? 
DD should be completely removed from DB?
-- select * from Course c join ScheduledIn s on c.course_id = s.course_id and c.division = s.course_division;
*/
-- (a) : 5 rows
select distinct(course_id) from ScheduledIn where room_number='2001';

-- (b) : 58 rows
select distinct(course_id) from ScheduledIn where slot_letter='C';

-- (c) : 4 rows
select distinct(course_division) from ScheduledIn where room_number in ('L2','L3');

-- (d) : 32 rows
select course_id from ScheduledIn group by course_id having count(distinct room_number) > 1;
--checker: select distinct course_id, room_number from ScheduledIn where course_id in (select course_id from ScheduledIn group by course_id having count(distinct(room_number)) > 1)order by course_id;

-- (e) : 8 rows
select distinct(name) from Department where department_id in (select department_id from ScheduledIn where room_number in ('L2','L3','L1','L4'));

-- (f) : 5 rows
select distinct(name) from Department where department_id not in (select department_id from ScheduledIn where room_number in ('L2','L1'));

-- (g) : 0 rows
set @totalSlots := (select count(*) from Slot);
select department_id,count(distinct slot_letter,slot_day) as slotCount from ScheduledIn group by department_id having slotCount = @totalSlots;
-- checker select department_id,count(distinct slot_letter,slot_day) as slotCount from ScheduledIn group by department_id order by slotCount;

-- (h) : 55 rows
select slot_letter,slot_day,count(distinct course_id,course_division) as courseCount from ScheduledIn group by slot_letter,slot_day order by courseCount;

-- (i) : 55 rows
select room_number,count(distinct course_id,course_division) as courseCount from ScheduledIn group by room_number order by courseCount;

-- (j) : 1 rows
drop table if exists allassigned;
create temporary table allassigned as (select slot_letter,count(distinct course_id,course_division) as courseCount from ScheduledIn group by slot_letter order by courseCount);
set @min := (select min(courseCount) from allassigned);
select slot_letter,courseCount from allassigned where courseCount = @min;	

-- (k) : 10 rows
select distinct course_id as Minor,GROUP_CONCAT(slot_day,"-",slot_letter) as assignedSlots from ScheduledIn where course_id like '_____M' group by course_id;

-- (l) : 279 rows (without DD)
drop table if exists dept_slots;
create temporary table dept_slots select distinct department_id,slot_day,slot_letter as assignedSlots from ScheduledIn;
select department_id,day,letter from Slot,Department where (department_id,day,letter) not in (select * from dept_slots) order by department_id,day,letter;

-- GROUPED - select department_id,group_concat(day,letter) from Slot,Department where (department_id,day,letter) not in (select * from dept_slots) group by department_id;