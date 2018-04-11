
# coding: utf-8

# In[554]:

import pandas as pd
import numpy as np
import glob
import time
runflag=1
insertflag=1
single_record=-10 # index of record
max_num_records=120#00000
not_applieds={}


# In[555]:

data_dir="workshop_dataset/workshop_dataset1/";
all_files = glob.glob(data_dir+"*.json")
total_files = len(all_files)


# In[556]:

# Test the data for consistencies. 

# Check Identical columns in all files and
# Note Record Counts to tally with cassandra counts later
if(runflag == 1):
    i=0
    df_shapes=[]
    all_records = pd.DataFrame()
    time_taken = 0
    prev_time = time.time()
    for filename in all_files:
        #the dtype is important for correctness. https://stackoverflow.com/questions/49627084/pandas-read-json-reads-large-integers-as-strings-incorrectly
        df=pd.read_json(filename,orient='index',convert_dates=False,convert_axes=False,dtype={"tid": int})            
        df_shapes.append(df.shape)
        curr_set = set(df)
        if(i>0):
            all_records = pd.concat([all_records,df])
            if(prev_set != curr_set):
                runflag=1
                print(filename, "New columns found!", curr_set - prev_set)
                break
        else:
            all_records=df
        runflag=0
        if(all_records.shape[0] > max_num_records):
            break
        prev_set = curr_set
        i+=1
    time_taken= time.time()-prev_time

    # Rename columns that are keywords
    all_records = all_records.rename(columns={'date':'tweet_date','datetime':'tweet_datetime'})
    # convert dates to datetime objects
    all_records['tweet_date'] = pd.to_datetime(all_records['tweet_date'])
    all_records['tweet_datetime'] = pd.to_datetime(all_records['tweet_datetime'])
    all_records['verified']=all_records['verified'].astype(bool)
    # convert lists to str as the python driver doesn't do it before utf-encode 
    # list_columns=['hashtags', 'keywords_processed_list', 'mentions', 'url_list']
    # for c in list_columns:
    #     all_records[c]=all_records[c].astype(str)

total_records= sum([ x for x,y in df_shapes])
total_records2= all_records.shape[0]
if(total_records!=total_records2):
    print("Error: Something's wrong with dataset, total counts not matching!",total_records,total_records2)
if(runflag==0):
    print("Done scanning %d files with total of %d records(%.2f records/file), in %.2f seconds(%.2f files/sec)" %
          (total_files, total_records, float(total_records)/total_files,time_taken, float(total_files)/time_taken))

# Ensure data types are correct in the dataframe-


# In[557]:

from cassandra.query import UNSET_VALUE
# from cassandra.util import OrderedMap

#debuggin
all_records_tail = all_records.tail(max_num_records)
all_columns = all_records_tail.columns.values # or list(df)
insert_records = all_records_tail.as_matrix()
# Handling NULLs -
# https://www.datastax.com/dev/blog/python-driver-2-6-0-rc1-with-cassandra-2-2-features
def handleNullInts(row):
    for i,val in enumerate(row):
#         if(type(val)==dict):
#             Convert keys to integers
#             row[i] = OrderedMap(row[i])
        # floats to ints coz pandas uses float which supports NoneTypes too, ints can't support this in pandas!
        # float_columns=['quoted_source_id', 'replyto_source_id', 'retweet_source_id']
        # Changing Cassandra columns to float as NULL support required.
        if(type(val)==float):
            if np.isnan(val):
#                 print("None Set for index",i,val)
                row[i]= UNSET_VALUE 
            else:                
                row[i]= int(row[i])

for record in insert_records:
    handleNullInts(record)

# print(insert_records[0])

# ^^ Can use this migration method as well: https://datastax.github.io/python-driver/object_mapper.html


# In[572]:

"""dot.notation access to dictionary attributes"""
class dotdict(dict):
   __getattr__ = dict.get
   __setattr__ = dict.__setitem__
   __delattr__ = dict.__delitem__
   
# import importlib
# importlib.reload(iquery) # Reloads modules in interactive shell
# https://stackoverflow.com/questions/1254370/reimport-a-module-in-python-while-interactive
# %load_ext autoreload
# %autoreload 2
columns={}
# Normal table
columns['hashtag_locations']=('hashtag', 'location' ) 
columns['hashtag_mention_list']=('hashtag', 'mentions' ,'tweet_date' ) 
# Needs completely diff function
columns['locations_by_hashtag']=( 'hashtag', 'location' ,'location_count') 
columns['hashtag_mentions']=('hashtag', 'mention' ,'tweet_date') 

statements={}
for table in columns.keys():
	cols=columns[table]
	statements[table]="insert into twitterdb."+table+" ("+",".join(cols)+") values (" + "?,"*(len(cols)-1)+"?" + ") if not exists";

   
# columns['tids_by_author']=('author_screen_name','author', 'author_id', 'tid', 'tweet_date', 'tweet_datetime' )
iquery=dotdict({
   'columns':columns,
   'statements':statements
})


# In[573]:

# Create individual record arrays here
# import insert_queries as iquery # local file having insert statements
insert_tables = iquery.columns.keys()
table_records={}
tally_counts={}
custom_col_tables=['tids_by_keyword','tids_by_hashtag','hashtag_locations','hashtag_mention_list', 'tids_by_mention'];
custom_col_listnames={
    'keyword':'keywords_processed_list',
    'hashtag':'hashtags',
    'mention':'mentions'
}

def getindex(all_columns,c):
    return np.where(all_columns == c)[0][0]

def getcolname(all_columns,c):
    if(c in custom_col_listnames.keys()):
        return custom_col_listnames[c]
    else:
        return c
special_table='locations_by_hashtag'
special_table2='hashtag_mentions'
exclude_tables=['hashtag_locations','hashtag_mention_list']

for t in insert_tables:
    if(t==special_table or t==special_table2):
        continue
    else:
        columns=iquery.columns[t]
        print('')
        print(columns)
        partition_key = getindex(all_columns,getcolname(all_columns,columns[0]))    
        filtered_records = insert_records[insert_records[:,partition_key] != None] #No floats used, so no need to check UNSET_VALUE
        rem_indices = [ getindex(all_columns,c) for c in columns[1:] if c in all_columns]
        if(t in custom_col_tables):    
            list_records = filtered_records[:,partition_key]
            expanded_records=[]
            for row_no,row in enumerate(list_records):
                for list_item in row:
                    #Works only on first col
                    expanded_records.append(np.concatenate([[list_item],filtered_records[row_no][rem_indices]]))
            table_records[t]=expanded_records
        else:
            table_records[t]= filtered_records[:,[i for i in [partition_key]+rem_indices]]
    print(t, table_records[t][0][0])
    print(len(insert_records),"-->",len(table_records[t]))
    tally_counts[t]=len(table_records[t])


# In[574]:

t='hashtag_locations'
t2='hashtag_mention_list'
df = pd.DataFrame(table_records[t],columns=iquery.columns[t]).dropna()
df2 = pd.DataFrame(table_records[t2],columns=iquery.columns[t2]).dropna()

print(df.count())
print(df2.count())


# In[575]:

hashtag_locations={}
for hashtag,rows in df.groupby('hashtag'):
    counts=rows.groupby('location').count()
    for l,c in counts.iterrows():
        hashtag_locations[hashtag] = c.name,c.hashtag

items = list(hashtag_locations.items())
table_records[special_table]= [ [l[0]]+list(l[1]) for l in items ]
tally_counts[special_table]=len(table_records[special_table])
print(tally_counts[special_table])
print(special_table,table_records[special_table][:10])
    


# In[576]:

hashtag_mentions=[]
for hashtag,rows in df2.groupby('hashtag'):
#     print(hashtag)
    tdate= list(rows.tweet_date)[0]
    for ms in rows['mentions']:
        for m in ms:
            hashtag_mentions.append([hashtag,m,tdate])
#             print(hashtag,m)
#     print('')
hm = pd.DataFrame(hashtag_mentions)
table_records[special_table2] =hm.as_matrix()
# df = hm.drop_duplicates()
# df = hm.groupby( list(hm),as_index=False).size()
tally_counts[special_table2]=len(table_records[special_table2])

print(tally_counts[special_table2])
print(special_table2,table_records[special_table2][:10])


# In[577]:

# #Nope- df.sort_values(by=['tweet_datetime','hashtag'],ascending=[False,True])
# df = pd.DataFrame(table_records['tids_by_hashtag'],columns=['hashtag','tid','tweet_date','tweet_datetime'])
# date_col='tweet_date'
# df = df[['hashtag',date_col]]
# hashtag_counts={}
# for day,rows in df.groupby(date_col,sort=True): #keys are sorted
#     hashtag_counts[day] = rows['hashtag'].value_counts()
# #     print(hashtag_counts[day])
# #     print(rows.groupby('hashtag').count())

# accum_sum = pd.DataFrame(hashtag_counts).fillna(0)
# # https://pandas.pydata.org/pandas-docs/stable/generated/pandas.DataFrame.rolling.html
# accum_sum = accum_sum.rolling(7,axis=1,min_periods=1).sum()
# accum_sum.sample(10)


# In[578]:

insertflag=1
# single_record=10;


# In[580]:

from cassandra.cluster import Cluster
from cassandra.concurrent import execute_concurrent, execute_concurrent_with_args
cluster = Cluster(['127.0.0.1'])

session = cluster.connect('twitterdb') # keyspace name should be lowercase
# added 'if not exists' at end
# tweets_by_tid_stmt = session.prepare(iquery.statementstweets_by_tid)
prepared_statements={}
for t in insert_tables:
    if(t not in exclude_tables):
        prepared_statements[t]=session.prepare(iquery.statements[t])
    
# Note that it will overwrite data without error (use 'IF NOT EXISTS' and check applied == False)
# session.execute(statement,insert_records[0])

if(insertflag==1):
    print("Inserting Records..")
    prev_time = time.time()
    if single_record > -1:
#         print("media_list", insert_records[single_record][11])
        for t in insert_tables:
            if(t not in exclude_tables):
                print(t)
                results = session.execute(prepared_statements[t],table_records[t][single_record])
    
        result_set=[dotdict({'success':True,'result_or_exc' : results})]
        total_inserted=1
    else:
        for t in insert_tables:
            if(t not in exclude_tables):
                print(t)
#                 print(table_records[t][:10])
                result_set = list(execute_concurrent_with_args(session, prepared_statements[t], table_records[t], concurrency=50))
        # One can iterate only once on this result_set!
        # That is useful when you do pagination: https://datastax.github.io/php-driver/api/Cassandra/class.Rows/
#         result_set = list(execute_concurrent_with_args(session, statement, insert_records, concurrency=50))
        total_inserted = total_records
    insertflag=0;
    time_taken=time.time()-prev_time    
            
print("Total Time taken for Insertion: %.2f seconds"% (time_taken) )
# print("Time taken for Insertion: %.2f seconds, %.2f records/second "% (time_taken, total_inserted/time_taken) )

# print("Reviewing inserts..")
# for row_no,r in enumerate(result_set):
#     if(r.success == True):
#         results = list(r.result_or_exc)
#         if(len(results)>0 and not results[0].applied):
#             not_applieds[row_no] = results[0].tid
# #             print(row_no,"Row already exists for tid:",results[0].tid)      
#     else:
# #         not_applieds[row_no] = r.result_or_exc
#         print(row_no,"Insertion failed with exception: ", r.result_or_exc)
# print("Not inserted (already exists): ",len(not_applieds),not_applieds)

for t in insert_tables:
    if(t not in exclude_tables):
        print("Getting counts for",t)
        prev_time = time.time()
        count = session.execute('select count(*) from '+t);
        print("Count:",count[0].count, tally_counts[t], tally_counts[t] - count[0].count,", Time taken for Count query: %.2f seconds"% (time.time()-prev_time) )


# https://datastax.github.io/python-driver/user_defined_types.html
# Note:  However, you must register a class to insert UDT columns with unprepared statements.

"""
Frozen value: Ensures the dict is updated entirely(NULLs allowed, but all parameters should be present), also acts as a workaround for nested collection types
A frozen value serializes multiple components into a single value. Non-frozen types allow updates to individual fields. Cassandra treats the value of a frozen type as a blob. The entire value must be overwritten.
"""

# print(total_records,count[0].count, abs(total_records - count[0].count))

session.shutdown(); # for use by cqlsh
cluster.shutdown();


# In[ ]:

# #Does retweet_count == 0 mean mentions are null ? 
# temp_all_records = all_records[all_records['retweet_count']==0]
# temp_all_records[temp_all_records['mentions']==None]


# In[45]:

# not_applieds={2773: 951604610837467136, 3020: 950878799305961472, 9514: 960301927337775104, 9844: 958851807593209856, 15754: 969360953581043712, 16162: 969361297165963264, 16278: 969361534311895040, 20671: 958126766564040704, 20803: 958126981387866112, 21704: 945081050019090432, 22358: 945081433206423552, 22396: 945081436838793216, 31615: 971172662465658880, 32194: 971173278445441024, 34112: 970810803921326080, 34692: 954865213609795584, 34910: 954865477473460224, 34988: 954865493625704448, 37475: 941820159093653504, 44091: 970086099082096640, 49572: 944354996942000128, 55415: 936383444157841408, 60292: 950154991536427008, 64977: 966462426865651712, 68258: 963925026406879232, 74102: 971898252697124864, 80051: 941095303838658560, 86902: 968999101789626368, 91561: 938195997381025792, 91877: 938196280345366528, 94693: 970448511434190848, 95226: 941457244117458944, 95824: 941457662843260928, 101775: 951241429061459968, 107326: 940732774901829632}


# In[55]:

# i=0;
# for row_no, tid in not_applieds.items():
#     if(insert_records[row_no][20] == tid or insert_records[row_no+1][20] == tid ):
#         i+=1
#         print(i,tid,"Conflict at row index",row_no,insert_records[row_no][20],row_no+1,insert_records[row_no+1][20],row_no-1,insert_records[row_no-1][20])#,insert_records[row_no+1])
        


# In[ ]:



