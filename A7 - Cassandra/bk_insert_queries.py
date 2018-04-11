columns={}
# columns['tweets_by_tid']=('tid','author', 'author_id', 'author_profile_image', 'author_screen_name', 'hashtags', 'keywords_processed_list', 'lang', 'like_count', 'location', 'media_list', 'mentions', 'quote_count', 'quoted_source_id', 'reply_count', 'replyto_source_id', 'retweet_count', 'retweet_source_id', 'sentiment', 'tweet_text', 'tweet_date', 'tweet_datetime', 'type', 'url_list', 'verified' )
# columns['tweets_by_author']=('author_screen_name','author', 'author_id', 'lang', 'location', 'tid', 'tweet_text', 'tweet_date', 'tweet_datetime', 'like_count', 'author_profile_image', 'hashtags', 'keywords_processed_list', 'media_list', 'mentions', 'quote_count', 'quoted_source_id', 'reply_count', 'replyto_source_id', 'retweet_count', 'retweet_source_id', 'sentiment', 'type', 'url_list', 'verified' )
# columns['tids_by_date']=('tweet_date', 'like_count', 'tweet_datetime', 'tid' )
# # Requires Removing nulls: Let's do it general _/
# columns['tids_by_location']=('location', 'tid', 'tweet_date', 'tweet_datetime' ) 

# # # Contains some custom columns-
# columns['tids_by_hashtag']=('hashtag', 'tid', 'tweet_date', 'tweet_datetime' ) 
columns['hashtag_locations']=('hashtag', 'location' ) 
columns['hashtag_mention_list']=('hashtag', 'mentions' ,'tweet_date' ) 
# columns['tids_by_mention']=('mention', 'tid', 'tweet_date', 'tweet_datetime' ) 
# columns['tids_by_keyword']=('keyword', 'tid', 'like_count' ) 

# Needs completely diff function
# columns['popular_hashtags']=( 'hash_date', 'hashtag_count', 'hashtag' ) 
columns['locations_by_hashtag']=( 'hashtag', 'location' ,'location_count') 
columns['hashtag_mentions']=('hashtag', 'mention' ,'tweet_date') 

statements={}
for table in columns.keys():
	cols=columns[table]
	statements[table]="insert into twitterdb."+table+" ("+",".join(cols)+") values (" + "?,"*(len(cols)-1)+"?" + ") if not exists";


# columns['tids_by_author']=('author_screen_name','author', 'author_id', 'tid', 'tweet_date', 'tweet_datetime' )
