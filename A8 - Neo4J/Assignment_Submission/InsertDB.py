
# coding: utf-8

# In[420]:

import pandas as pd
import numpy as np
import time
runflag=1
insertflag=1
NULL_INT=-1
single_record=-10 # index of record
max_num_records=1200#0000
not_applieds={}
data_dir="workshop_dataset/workshop_dataset1/";


# In[421]:

all_files = ["dataset.json"]
# glob.glob(data_dir+"*.json")
file=all_files[0]


# In[422]:

# Test the data for consistencies and make it importable
if(runflag == 1):
    total_files=0
    df_shapes=[]
    all_records = pd.DataFrame()
    time_taken = 0
    prev_time = time.time()
    for filename in all_files:
        df=pd.read_json(filename,orient='index',convert_dates=False,convert_axes=False,dtype={"tid": int})            
        df_shapes.append(df.shape)
        curr_set = set(df)
        total_files+=1
        if(total_files==1):
            all_records=df
        else:
            all_records = pd.concat([all_records,df])
            if(prev_set != curr_set):
                runflag=1
                print(filename, "New columns found!", curr_set - prev_set)
                break
        runflag=0
        if(all_records.shape[0] > max_num_records):
            break
        prev_set = curr_set
    time_taken= time.time()-prev_time

    # Rename columns that are keywords
    all_records = all_records.rename(columns={'date':'tweet_date','datetime':'tweet_datetime'})
    all_records['verified']=all_records['verified'].astype(bool)
    all_records['tid']=all_records['tid'].astype(int)
#     all_records['quoted_source_id']=all_records['quoted_source_id'].fillna(NULL_INT).astype(int)
#     all_records['replyto_source_id']=all_records['replyto_source_id'].fillna(NULL_INT).astype(int)
#     all_records['retweet_source_id']=all_records['retweet_source_id'].fillna(NULL_INT).astype(int)
    

total_records= sum([ x for x,y in df_shapes])
total_records2= all_records.shape[0]
if(total_records!=total_records2):
    print("Error: Something's wrong with dataset, total counts not matching!",total_records,total_records2)
if(runflag==0):
    print("Done scanning %d file(s) with total of %d records(%.2f records/file), in %.2f seconds(%.2f files/sec)" %
          (total_files, total_records, float(total_records)/total_files,time_taken, float(total_files)/time_taken))


# In[423]:

from py2neo import Graph, Node, Relationship
g = Graph()
g.delete_all()

#clean the graph
insert_nodes=1
insert_rels=1


# In[424]:

uniq_constraints={
    'Author':["author_id","author_screen_name"],
    'Tweet': ["tid",],
    'Media':[ 'media_id',],
    'Url':[ 'url', ], 
    'Keyword':[ 'keyword', ], 
    'Location':[ 'location', ], 
    'Hashtag':[ 'hashtag', ] 
}
#Adding unique also adds index
for k,v in uniq_constraints.items():
    for attr in v:
        print("CREATE CONSTRAINT ON ({0}:{0}) ASSERT {0}.{1} IS UNIQUE".format(k,attr))
        #Try catch blocks so that this code can be repeatedly run without issues
        try:
            g.run("DROP CONSTRAINT ON ({0}:{0}) ASSERT {0}.{1} IS UNIQUE".format(k,attr))
        except:
            try:
                g.run("CREATE CONSTRAINT ON ({0}:{0}) ASSERT {0}.{1} IS UNIQUE".format(k,attr))
            except:
                g.run("DROP INDEX ON :{0}({1});".format(k,attr))
                g.run("CREATE CONSTRAINT ON ({0}:{0}) ASSERT {0}.{1} IS UNIQUE".format(k,attr))

        


# In[425]:

import time
prev_time= time.time()
tx=graph.begin()
media_cols=[ 'media_id', 'media_type', 'display_url', 'media_url', ]
for index, row in all_records.iterrows():
    params=row.to_dict()
    
    m_item_list=[]
    if(params['media_list'] is not None):
        for r in params['media_list'].values():
            m_item_list.append([ m_item[c] for c in media_cols])
    params['list_media_items']=m_item_list
    statement="""
      MERGE (p:Author {author_id: {author_id}})
          REMOVE p:Shadow
          SET p.author = {author},
              p.author_screen_name = {author_screen_name},
              p.author_profile_image = {author_profile_image}
          
      MERGE (t:Tweet {tid: {tid}})
          REMOVE p:Shadow
          SET t.type = {type},
              t.tweet_date = {tweet_date},
              t.tweet_datetime = {tweet_datetime},
              t.tweet_text = {tweet_text},
              t.quote_count = {quote_count},
              t.reply_count = {reply_count},
              t.like_count = {like_count},
              t.sentiment = {sentiment},
              t.retweet_count = {retweet_count},
              t.verified = {verified},
              t.lang = {lang},
              t.like_count = {like_count}
      MERGE (p)-[:WROTE]->(t)
       
      FOREACH(locn in CASE WHEN NOT {location} is null THEN[1] ELSE [] END |        
        MERGE (loc:Location {location: {location}})
        MERGE (t)-[:AT]->(loc)
      )            

      FOREACH( htag IN {hashtags} |
        MERGE (htg:Hashtag {hashtag: htag})
        ON CREATE SET htg:Shadow
        MERGE (t)-[:HAS_HASHTAG]->(htg)
      ) 
      
      FOREACH( mention IN {mentions} |
        MERGE (mnt_node:Mention {mention: mention})
        ON CREATE SET mnt_node:Shadow
        MERGE (mnt_node)-[:MENTIONED_IN]->(t)
      )

      FOREACH( u IN {url_list} |
        MERGE (url_node:Url {url: u})
        ON CREATE SET url_node:Shadow
        MERGE (t)-[:HAS_URL]->(url_node)
      )

      FOREACH( k IN {keywords_processed_list}|
        MERGE (keyword_node:Keyword {keyword: k})
        ON CREATE SET keyword_node:Shadow
        MERGE (t)-[:HAS_KEYWORD]->(keyword_node)
      )

    """
    tx.append(statement, params)
    tx.process()
tx.commit()
time_nodes=time.time()-prev_time
print("Insertion Time:",time_nodes)


# In[426]:

# Adding indices may take time. And make inserts slow. Hence do after inserts    
# Except for necessary unique ones which are done before insert
indices={
    #Wherever we gonna search which was not covered in unique
    'Tweet' : ['type','tweet_date','tweet_datetime',],
}
for k,v in indices.items():
    for attr in v:
        g.run("CREATE INDEX ON :{0}({1});".format(k,attr))
        print("CREATE INDEX ON :{0}({1});".format(k,attr))
        


# In[427]:

# all_hashtags=[]
# for i,row in all_records.iterrows():
#     if(row.hashtags):
#         all_hashtags+=row.hashtags
        
# df = pd.DataFrame([ [h] for h in all_hashtags],columns=['hash']).groupby(['hash'])
# for hashtag,rows in df:
#     counts=rows.groupby('location').count()
#     for l,c in counts.iterrows():
#         hashtag_locations[hashtag] = c.name,c.hashtag



# In[ ]:



