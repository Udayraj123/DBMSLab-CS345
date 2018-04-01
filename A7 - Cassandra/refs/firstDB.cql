DROP KEYSPACE IF EXISTS FirstDB;

CREATE KEYSPACE FirstDB WITH replication = {'class': 'SimpleStrategy', 'replication_factor' : 1};

use FirstDB;

CREATE TABLE monkeySpecies (
	species text PRIMARY KEY,
	common_name text,
	population varint,
	average_size int
) WITH comment='Important biological records'
AND read_repair_chance = 1.0;

CREATE TABLE timeline (
	userid uuid,
	posted_month int,
	posted_time uuid,
	body text,
	posted_by text,
	PRIMARY KEY (userid, posted_month, posted_time)
) WITH compaction = { 'class' : 'LeveledCompactionStrategy' };

CREATE TABLE loads (
	machine inet,
	cpu int,
	mtime timeuuid,
	load float,
    -- First key is partitioning, rest is clustering.
    PRIMARY KEY ((machine, cpu), mtime)
) WITH CLUSTERING ORDER BY (mtime DESC); -- CLUSTERING always orders data in partition, but you can specify explicitly 'ASC'/'DESC' for each of the clustering columns

CREATE TABLE t (
	a int,
	b int,
	c int,
	d int,
    PRIMARY KEY ((a, b), c, d) -- First key is partitioning, rest is clustering.
);

COPY FirstDB.t FROM 'table_t.csv' WITH DELIMITER='|' AND HEADER=TRUE;

-- Note that a table always has a partition key, and that if the table has no clustering columns, 
-- then every partition of that table is only comprised of a single row (since 
-- the primary key uniquely identifies rows and the primary key is equal to the partition key 
-- if there is no clustering columns).

-- The clustering columns of a table defines the clustering order for the partition of that table. 
-- For a given partition, all the rows are physically ordered inside Cassandra by that clustering order

-- See partitions from this query: (ref: https://stackoverflow.com/questions/46166650/view-cassandra-partitions-using-cqlsh)
select token(a,b) as Partition,a,b,c,d from t;
-- Just remember that A select without any condition clause is a very costly operation as
-- Cassandra has to fetch this data from all nodes in the cluster that has any data for that table. 

-- Command to find which node the partition is stored at
-- nodetool getendpoints firstdb t '0:0'

-- User defined type: 
CREATE TYPE vertex (
	x int,
	y int,
	z int
);

CREATE TABLE my_poly (
	pos vertex,
	val int,
	-- PRIMARY KEY (vertex, val) -- custom type cannot be a primary key?!
	PRIMARY KEY (val)
);


CREATE TABLE user_details
(
	screen_name TEXT PRIMARY KEY,
	created_date TIMESTAMP,
	location TEXT,
	twitter_id BIGINT,
	url TEXT,
	user_name TEXT
	); 
CREATE TABLE follower_list
(
	user_screen_name TEXT PRIMARY KEY,
	followers LIST<text>
) 
insert into follower_list (user_screen_name, followers) 
	values (‘sam’, {‘friend1’,’friend2’});


	CREATE TABLE follower_details
	(
		user_screen_name TEXT,
		follower_screen_name TEXT,
		created_date TIMESTAMP,
		follower_user_name TEXT,
		location TEXT,
		twitter_id BIGINT,
		url TEXT,
	  -- How you design the primary key matters the most. 
	  -- Noting that CQL's ad-hoc design doesn't support JOINS,
	  -- making user_screen_name the partition key allows listing user-wise followers as well as followers alone.
		-- making follower_screen_name the clustering key 
		PRIMARY KEY (user_screen_name, follower_screen_name)
		); 

	-- Imagine a stream of tweets going to the right, from a user's screen_name.
	-- Each row is dedicated to one user.
	-- The horizontal stream of tweets is a ever-growing column family,
	-- Now to even speed up reads, we can compromise on writes(which cassandra is pretty fast at) 
	-- and some query conditions (only minute-wise tweets will be trackable),
	-- by making combination of screen_name and timestamp as the row key (partition key)
	-- Note:  If the keys are repeated then the data will be overwritten.
	CREATE TABLE tweets_user_day
	(
		screen_name TEXT,
		published_day TIMESTAMP,
		published_date TIMESTAMP,
		actual_link TEXT,
		created_date TIMESTAMP,
		link TEXT,
		tweet_body TEXT,
		PRIMARY KEY ((screen_name, published_day, published_date)); 

-- To manage memory,etc, A column can also have an optional expiration date called TTL (time to live). Whenever a column is inserted, the client can request to specify an optional TTL value, defined in seconds, for the column.
-- TTL columns are marked as deleted (with a tombstone) after the requested amount of time has expired. Once they are marked with a tombstone, they are automatically removed during normal compaction and repair processes.
-- example:  insert into tweets_information (‘sam’,’2014-02-12 07:30:45’,’superb breakfast’) using TTL 60;
		CREATE TYPE tweets (
			x int,
			y int,
			z int
			);


-- https://www.aquaclusters.com/app/home/project/public/aquadatastudio/issue/9016
-- Cassandra does not behave as other databases, if key exists already, it actually performs an UPDATE (as the result of your last SELECT statement).

-- Below is from Cassandra CQL/INSERT document:

--   "Description
--       An INSERT writes one or more columns to a record in a Cassandra table atomically and in isolation. No results are returned. You do not have to define all columns, except those that make up the key. Missing columns occupy no space on disk.

--       If the column exists, it is updated. You can qualify table names by keyspace. INSERT does not support counters, but UPDATE does."

-- Note the last sentence mentions that "INSERT does not support counters" which means you cannot apply INSERT to a column defined as a 'counter' data type.


-- TODO: custom datatypes (scripts), 
