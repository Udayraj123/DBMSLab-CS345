DROP KEYSPACE IF EXISTS twitterdb;

CREATE KEYSPACE twitterdb WITH replication = {'class': 'SimpleStrategy', 'replication_factor' : 1};

use twitterdb;

CREATE TABLE twitter_table (
	author text,
	author_id bigint, -- 64-bit signed long
	author_profile_image text,
	author_screen_name text,
	hashtags list, 
	keywords_processed_list list,
	lang text,
	like_count bigint,
	location text,
	media_list map,
	mentions list,
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
	url_list list,
	verified boolean,
	primary key( tid )
) WITH comment='Generated with help of pandas.io utilities';

-- insert biginto twitter_table 
-- (author, author_id, author_profile_image, author_screen_name, date, datetime, hashtags, keywords_processed_list, lang, like_count, location, media_list, mentions, quote_count, quoted_source_id, reply_count, replyto_source_id, retweet_count, retweet_source_id, sentiment, tid, tweet_text, type, url_list, verified)
-- values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)