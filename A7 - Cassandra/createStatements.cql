DROP KEYSPACE IF EXISTS twitterdb;

CREATE KEYSPACE twitterdb WITH replication = {'class': 'SimpleStrategy', 'replication_factor' : 1};
-- SelfNote: If you get unknown type error, or any unexpected weird error, think if it's coz of unsynced commit logs
-- https://stackoverflow.com/questions/10359592/cassandra-assertionerror

use twitterdb;

CREATE TABLE twitterdb.tweets_by_tid (
	author text,
	author_id bigint,
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
	sentiment int,
	tid bigint, --128 bit integer
	-- tid bigint,
	tweet_text text,
	tweet_date TIMESTAMP,
	tweet_datetime TIMESTAMP,
	type text,
	url_list list<text>,
	verified boolean,
	-- GROUPING_COLS, ORDERING_COLS ---> Increasing Specificity
	primary key( tid, tweet_date, tweet_datetime ) -- For searching by tweet's id
) WITH comment='Main table containing all data from json, used for loading tweets'
-- TODO: Check execution time delta when this is disabled 
AND CLUSTERING ORDER BY (tweet_date DESC, tweet_datetime DESC);

-- Can't clone and edit the tables as Primary key cannot be altered in cassandra.

-- Test table with all attributes to see how it goes. Have to duplicate this way.
CREATE TABLE twitterdb.tweets_by_author (
	author text,
	author_id bigint, -- fixed for a user
	author_screen_name text, --changable by user 
	lang text,
	location text,
	tid bigint, --128 bit integer
	tweet_text text,
	tweet_date TIMESTAMP,
	tweet_datetime TIMESTAMP,

	like_count bigint,

	author_profile_image text,
	hashtags list<text>, 
	keywords_processed_list list<text>,
	media_list map <text, frozen< map < text, text > > >, -- dict types
	mentions list<text>,
	quote_count bigint,
	quoted_source_id bigint,
	reply_count bigint,
	replyto_source_id bigint,
	retweet_count bigint,
	retweet_source_id bigint,
	sentiment int,
	type text,
	url_list list<text>,
	verified boolean,
	primary key( author_id, tweet_date, tweet_datetime, tid )-- tid ensures uniqueness 
) WITH comment='Contains tweets partitioned by an author_id, used for queries of type 1'
AND CLUSTERING ORDER BY (tweet_date DESC, tweet_datetime DESC);

-- There is no foreign key constraint in NoSQL, but still one can fetch them
CREATE TABLE twitterdb.tids_by_author (
	author text,
	author_id bigint, -- fixed for a user
	author_screen_name text, --changable by user 
	tid bigint, --128 bit integer
	tweet_date TIMESTAMP,
	tweet_datetime TIMESTAMP,
	primary key( author_id, tweet_date, tweet_datetime, tid) -- tid ensures uniqueness
) WITH comment='Contains tids partitioned by an author_id, used for queries of type 1'
AND CLUSTERING ORDER BY (tweet_date DESC, tweet_datetime DESC);


CREATE TABLE twitterdb.tids_by_date (
	tweet_date TIMESTAMP,
	tweet_datetime TIMESTAMP,
	tid bigint, --128 bit integer
	primary key( tweet_date, tweet_datetime, tid) -- tid ensures uniqueness
) WITH comment='Contains tweets partitioned by dates, used for queries of type 2 and 5'
-- Using special characters like & or \' is not allowed in comments
AND CLUSTERING ORDER BY (tweet_datetime DESC,tid DESC);

-- Multiple Inserts per tweet maybe required
CREATE TABLE twitterdb.tids_by_hashtag (
	hashtag text,
	tid bigint, --128 bit integer
	tweet_date TIMESTAMP,
	tweet_datetime TIMESTAMP,
	primary key( hashtag, tweet_date, tweet_datetime, tid) -- tid ensures uniqueness
) WITH comment='Contains an entry for each hashtag used in a tweet, used for queries of type 3'
AND CLUSTERING ORDER BY (tweet_date DESC, tweet_datetime DESC);

-- Multiple Inserts per tweet maybe required
CREATE TABLE twitterdb.tids_by_mention (
	mention text,--mentioned author
	tid bigint, --128 bit integer
	tweet_date TIMESTAMP,
	tweet_datetime TIMESTAMP,
	primary key( mention, tweet_date, tweet_datetime, tid) -- tid ensures uniqueness
) WITH comment='Contains tweets partitioned by mentioned author, used for queries of type 4'
AND CLUSTERING ORDER BY (tweet_date DESC, tweet_datetime DESC);

-- Multiple Inserts per tweet maybe required
-- and Non-nulls shouldn't be inserted
CREATE TABLE twitterdb.tids_by_location (
	location text,
	tid bigint, --128 bit integer
	tweet_date TIMESTAMP,
	tweet_datetime TIMESTAMP,
	primary key( location, tweet_date, tweet_datetime, tid) -- tid ensures uniqueness
) WITH comment='Contains tweets partitioned by an location, used for queries of type 6'
AND CLUSTERING ORDER BY (tweet_date DESC, tweet_datetime DESC);



-- Indexing is required before using the CONTAINS keyword
-- CREATE INDEX hashtags_search_en ON tweets_by_date(hashtags);
-- CREATE INDEX mentions_search_en ON tweets_by_date(mentions);

-- User defined type: 
-- CREATE TYPE twitterdb.media_list_item (
-- 	media_id text,
-- 	media_type text,
-- 	display_url text,
-- 	media_url text
-- );
-- ^^ Comments at the end of file will give "Incomplete statement at end of file" error
-- http://grokbase.com/t/cassandra/user/13a2mrms0q/issue-with-source-command-and-utf8-file

-- Multiple Inserts per tweet maybe required
CREATE TABLE twitterdb.hashtag_counter (
	-- Keeps daily count so that any range of days can be queried
	hash_week TIMESTAMP, -- Reduces to max 2 nodes from max 7.
	hash_date TIMESTAMP,
	hashtag text,
	hashtag_count bigint,
	primary key( hash_week, hash_date, hashtag)
) WITH comment='Contains tweets partitioned by an location, used for queries of type 6'
AND CLUSTERING ORDER BY (hash_date DESC, hashtag ASC);
