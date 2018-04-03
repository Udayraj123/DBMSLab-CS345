DROP KEYSPACE IF EXISTS twitterdb;

CREATE KEYSPACE twitterdb WITH replication = {'class': 'SimpleStrategy', 'replication_factor' : 1};
-- If you get unknown type error, or any unexpected weird error, think if it's coz of unsynced commit logs
-- https://stackoverflow.com/questions/10359592/cassandra-assertionerror

use twitterdb;

-- User defined type: 
-- CREATE TYPE twitterdb.media_list_item (
-- 	media_id text,
-- 	media_type text,
-- 	display_url text,
-- 	media_url text
-- );

CREATE TABLE twitterdb.twitter_table (
	author text,
	author_id bigint, -- 64-bit signed long
	author_profile_image text,
	author_screen_name text,
	hashtags list<text>, 
	keywords_processed_list list<text>,
	lang text,
	like_count bigint,
	location text,
	-- media_list map <text, frozen <media_list_item> >, -- frozen will serialize stuff too
	media_list map <text, frozen< map < text, text > > >, -- dict types
	mentions list<text>,
	quote_count bigint,
	quoted_source_id bigint,
	reply_count bigint,
	replyto_source_id bigint,
	retweet_count bigint,
	retweet_source_id bigint,
	sentiment bigint,
	tid bigint,
	tweet_text text,
	tweet_date TIMESTAMP,
	tweet_datetime TIMESTAMP,
	type text,
	url_list list<text>,
	verified boolean,
	primary key( tid )
) WITH comment='Generated with help of pandas.io utilities';

-- insert biginto twitter_table 
-- (author, author_id, author_profile_image, author_screen_name, date, datetime, hashtags, keywords_processed_list, lang, like_count, location, media_list, mentions, quote_count, quoted_source_id, reply_count, replyto_source_id, retweet_count, retweet_source_id, sentiment, tid, tweet_text, type, url_list, verified)
-- values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)