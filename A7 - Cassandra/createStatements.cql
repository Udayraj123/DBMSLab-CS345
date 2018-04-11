DROP KEYSPACE IF EXISTS twitterdb;

CREATE KEYSPACE twitterdb WITH replication = {'class': 'SimpleStrategy', 'replication_factor' : 1};

use twitterdb;

-- Multiple Inserts per tweet maybe required
CREATE TABLE twitterdb.locations_by_hashtag (
	hashtag text,
	location text,
	location_count bigint,
	primary key( hashtag, location_count, location)
) WITH comment='Contains popular hashtags partitioned by a date, used for queries of type 1'
AND CLUSTERING ORDER BY (location_count DESC,location ASC);

-- Multiple Inserts per tweet maybe required
CREATE TABLE twitterdb.hashtag_mentions (
	tweet_date TIMESTAMP,
	hashtag text,
	mention text,
	-- pair_count bigint, -- no need as GROUP BY is now added since 3.10
	primary key( tweet_date, hashtag, mention)
) WITH comment='Contains hashtag-mention pairs partitioned by a date, used for queries of type 2'
AND CLUSTERING ORDER BY (hashtag ASC,mention ASC);
