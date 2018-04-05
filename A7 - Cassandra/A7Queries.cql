-- 1. Given an author name, display all tweets posted by that author sorted by decreasing order of date and time. The details of the tweet must include the tweet Id, tweet text, tweet author Id, tweet location and tweet language.
-- Assumption: author name implies author_screen_name
select author_screen_name,author,tid,tweet_text,location,lang from twitter_table where
 author_screen_name = ?;
-- A table partitioned by author_screen_name

-- 2. Given a keyword, retrieve the tweets containing the keyword and sort them by their popularity in decreasing order. Popularity of a tweet is based on it's like-count. Higher the like-count, more the popularity.
select author_screen_name,author,tid,tweet_text,location,lang from twitter_table where tweet_text like '%?%'  order by like_count desc;
-- An expensive query for any partitioning...

-- 3. Given a hashtag, retrieve all tweets containing the hashtag and sort them in decreasing order of date and time. 
select author_screen_name,author,tid,tweet_text,location,lang,tweet_datetime from twitter_table where hashtags contains ?  order by tweet_datetime desc;
-- A table having hashtag(as partition key),a tid, and tweet_datetime, 

-- 4. Given an author name, retrieve all tweets that mentions the author. Sort them in decreasing order of date and time. 
-- Assumption: author name implies author_screen_name
select author_screen_name,author,tid,tweet_text,location,lang,tweet_datetime from twitter_table where mentions contains ?  order by tweet_datetime desc;
-- A table having mentioned_author(as partition key),a tid, and tweet_datetime, 


-- 5. Retrieve all tweets of a particular date sorted in decreasing order of their like count
select author_screen_name,author,tid,tweet_text,location,lang,tweet_datetime from twitter_table where
 tweet_date = ?  order by like_count desc;
-- A table(Curr. table) having tweet_date(as partition key),a tid, like_count and tweet_datetime, 

-- 6. Retrieve all tweets from a given location 
select author_screen_name,author,tid,tweet_text,location,lang,tweet_datetime from twitter_table where
 location = ?  order by tweet_datetime desc;
-- Cluster by location. Not coz of NULLs? <- Then Don't insert them into this table!
-- location, tid,  (clustering order desc)


-- 7. Given a date, retrieve top 20 most frequent hashtags over the last 7 days.
-- week, hashtag, hashtag_count (clustering order desc)

-- 8. Given a date, delete all tweets posted on that day. 
-- **Results of operation 8 may not be displayed in the interface
?? HAVE TO DELETE ALL CORRESPONDING ENTRIES IN OTHER TABLES TOO...
-- delete from twitter_table where tweet_date = ?;


-- TODO if time-
-- Possible visualizations: 
-- Distribution of column values:
--	 To justify the choice of partition keys in each table.
--	 To justify the non-choice of combined-with-date partition keys