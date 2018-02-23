#How to use
source loadAll.sql

#TODO 
[] Restore the ignored ME654 to demonstrate insert errors (See below)
[-] Handle "Other than Thursday" type cases (Ignored previously)

#Notes made during processing 
/*
CSV files-
They have different formats, hence they have to be manually rearranged to follow a standard format. 
Some of the depts have given in ScheduleIn format directly. Those cases need to be handled separately.
Strategy-
1. Converted all pdfs to xlsx (makes it easy to copy data)
2. Extract the tables containing schedules (remove extra clutters) and store it in a separate sheet.
3. Remove courses in lab slots

Special cases-
Design dept : much work (will insert later, first complete the code)
CSE n CH : converter failed, have to copy line by line carefully
EEE - handled the following exceptions as well-
# OE I	Room: L1	
* OE II/III	EE 664 (GT)	EE 671 (DS)
	Room: 3202	Room: 2101

	*/

Input csv:  Day Room Slot-A Slot-B    
M r1 c1 c2 ..   
M r2 None c3 ..   
M r3 c3 None ..   

T r1 c1 c2    
T r2 c2 None    
T r3 None c4    
.. .. .. ..    

Make daywise merge files. Which will then have all entries as rows        
Pandas will be useful to generate the sql        
As using C is not a compulsion        

And extend the dates column appropriately      location might need manual work, can make a dict though  
Final format :   slot day course room location division (only for Institute level)


*Do not forget to separate these sheets into individual csvs        
Two types of formats found : Weekday-based and Slot-based
The weekday-based needs to be checked once for conflict of slot change (esp in ME, which was visually seen)
    

Notes A course may not necessarily stick to one slot all week e.g : EE270, me 522 (always 5-6 everyday)       
A course can happen at multiple location at same time, e.g Tutorial courses Slot A       
Some courses have slots, but venue undecourse_ided e.g. BSBE open electives       
Institute courses mentioned on dept pdf are ignored, they will be picked from institute pdf only       

Institute Levels  Make single sheet for institute levels as they are less in number     
These strictly stick to the slot given. Can use special code for this      
Make the "SlotBased" sheet for above      

Special cases :       
PH needs color decoding for venues ! - But fortunately they consistently follow a pattern - Red Green Blue Black       
CH doesn't get converted to CSV (tried multiple sources), even Line by line copy is failing.       
CSE got converted by another one, but had 4-6 spaces instead of tab, replacing that helped partially       
ME seems the most inconsitent one,  multi pages, room no not in separate column, '-' instead of spaces at some places and also repeat entries of same slot-location-course       
"Ignored the “(other than Tuesday 8-8:55) [Institute]”, ""except Monday 5-5:55"" filters"
** A Conflict/Typo found in ME - In 12-1 slots at 1203, ME 654 and ME 554 both place, taking ME 554       
"** Incompatibility: DD doesn’t have a pattern of classes PER WEEK,
Solution?
Psble, but Nope - M1: add week numbers column in course. Which should have ‘ALL’ or a comma separated ordered list of week numbers as its value. 
As the Queries in Asgn 2 also get conflicted because of this, I’ll first run my code without DD"

#Now I have processed csvs - Mon Tue Wed Thur Fri and Slotbased
Steps to follow - 
Done = 1. Write a py script that checks for slot-consistencies accross the weekday-based files, Separate inconsitent ones to highlight, put others in Slotbased.
Found 99 MultiSlot Courses- in txt file in this directory
There exist 27 multiroom courses as well.
SelfNote: 
	Typo found during scripting - ME321 instead of ME321M, was showing 1 class perweek, corrected
	Also found interesting data - CE 402 has exactly one class per week.

Done = 2. Another script that generates the sql statements for entries &  for relations as well(some more processing may be required)
SelfNote: Another issue found : 
	Slotbased.csv had 29 duplicates! Of these -
	17(only some were duplicates) Electives from Institute were added (with added room numbers). 
		CL dept had put core names in room numbers (eg CL639, overridden now)
	3 Typos detected and corrected (different rooms)- 
		(elective) "BT632	C	4210" instead of "BT632	C	xxxx" in Slotbased
		"BT604	I	4210" instead of "BT604	B	4210"
		"BT629	K	4207" instead of "BT629	K	4210"
	12 common courses found in MA - had one entry each for BTech and MSc (with same rooms)
	1 Actual Conflict for CS526 - CSE.pdf says 2204, while Institute says L4, >> taking Institute one

	Significance of these 7 duplicates-
		CE552	C	4G3
		CE616	C	4001
		EE657	E1	L1
		EE664	C	3202
		EE671	C	2102
		PH443	C	4G4
		PH446	E1	4005		
	 Above are exactly the Intersection of Elective courses in Insitute.pdf and those mentioned by depts (EE,CE and PH) in their own timetable. Hence these need to be removed from one of the places, prefererring Institute one as it's easier (added count checks too).
	 CSE has mentioned too, but they have only one intersection CS526 which was removed from dept csv coz of venue conflict.

	 CH643 had "same venue as" CH438 - 4005 : manually added

Done = 3. Source the sqls into DB, check for constraint errors for clean(which u thought) ones, then separately add inconsitents.
4. Can you generate any useful visuals?

My Queries when this completes -         
1 What’s the busiest and freest academic hour?       
2 Calc free times for each venue   