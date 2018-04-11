<?php
$all_cols=['author', 'author_id', 'author_profile_image', 'author_screen_name', 'hashtags', 'keywords_processed_list', 'lang', 'like_count', 'location', 'media_list', 'mentions', 'quote_count', 'quoted_source_id', 'reply_count', 'replyto_source_id', 'retweet_count', 'retweet_source_id', 'sentiment', 'tid', 'tweet_text', 'tweet_date', 'tweet_datetime', 'type', 'url_list', 'verified' ];
$normal_cols_str='author_screen_name,author,tid,tweet_text,location,lang,tweet_datetime';
$cols1='hashtag,location,location_count';
$cols2='hashtag,mention,count(*) as pair_count';
return array(
	'query01'=> "select $cols1 from twitterdb.locations_by_hashtag where hashtag = ?",
	'query02'=> "select $cols2 from twitterdb.hashtag_mentions where tweet_date = ? group by hashtag,mention",

// 'query1'=> "select $normal_cols_str from twitterdb.tweets_by_author where author_screen_name = ?",
// 'query2'=> "select keyword,like_count,tid from twitterdb.tids_by_keyword where keyword = ?",
// // 'query2'=> "select $normal_cols_str from twitterdb.tids_by_keyword where keyword = ?",
// 'query3'=> "select $normal_cols_str from twitterdb.tids_by_hashtag where hashtag = ?",
// 'query4'=> "select $normal_cols_str from twitterdb.tids_by_mention where mention = ?",
// // 'query5'=> "select $normal_cols_str from twitterdb.tids_by_date where tweet_date = ?",
// 'query5'=> "select tweet_date,tweet_datetime,tid from twitterdb.tids_by_date where tweet_date = ?",
// 'query6'=> "select $normal_cols_str from twitterdb.tids_by_location where location = ?",
// 'query7'=> "select $normal_cols_str from twitterdb.popular_hashtags where counter = ?",
	);
