#Notes made during processing 

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
Some courses have slots, but venue undecided e.g. BSBE open electives       
Institute courses mentioned on dept pdf are ignored, they will be picked from institute pdf only       

Institute Levels  Make single sheet for institute levels as they are less in number     
These strictly stick to the slot given. Can use special code for this      
Make the "SlotBased" sheet for above      

Special cases :       
PH needs color decoding for venues ! - But fortunately they consistently follow a pattern - Red Green Blue Black       
CH doesn't get converted to CSV (tried multiple sources), even Line by line copy is failing.       
CSE got converted by another one, but had 4-6 spaces instead of tab, replacing that helped partially       
ME seems the most inconsitent one,  multi pages, room no not in separate column, '-' instead of spaces at some places and also repeat entries of same slot-location-course       
** A Conflict/Typo found in ME - In 12-1 slots at 1203, ME 654 and ME 554 both place, taking ME 554       
"** Incompatibility: DD doesn’t have a pattern of classes PER WEEK,
Solution?
Psble, but Nope - M1: add week numbers column in course. Which should have ‘ALL’ or a comma separated ordered list of week numbers as its value
As the Queries in Asgn 2 also get conflicted because of this, I’ll first run my code without DD"       
"Ignored the “(other than Tuesday
8-8:55) [Institute]”, ""except Monday 5-5:55"" filters"       

#Now I have processed csvs - Mon Tue Wed Thur Fri and Slotbased
Steps to follow - 
1. Write a py script that checks for slot-consistencies accross the weekday-based files, Separate inconsitent ones to highlight, put others in Slotbased.
2. Another script that generates the sql statements for relations (some more processing may be required) (for entries, we can use mysql workbench's import)
3. Source the sqls into DB, check for constraint errors for clean(which u thought) ones, then separately add inconsitents.
4. Can you generate any useful visuals?

My Queries when this completes -         
1 What’s the busiest and freest academic hour?       
2 Calc free times for each venue   