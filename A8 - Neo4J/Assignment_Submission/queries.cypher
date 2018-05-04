//7. Given the hashtag, retrieve the top 3 user-mentions (author_screen_names)
//that co-occur with this hashtag. A hashtag and a user-mention is said to be co-
//occurring if they co-occur in the same tweet (tweet_type : Tweet).. Sort the
//output in decreasing order of co-occurrence count. Your output should include
//the following:
//Hashtag – User-mention – Tweet-ids where the user mention and the hashtag
//co-occur – Co-occurrence count

// for Graph
MATCH (m:Mention)-[mt:MENTIONED_IN]->(t:Tweet{type:'Tweet'})-[th:HAS_HASHTAG]->(h:Hashtag{hashtag: 'HappyBirthdayJustinBieber'})  
return m,mt,t,th,h

// for Table
MATCH (m:Mention)-[mt:MENTIONED_IN]->(t:Tweet{type:'Tweet'})-[th:HAS_HASHTAG]->(h:Hashtag{hashtag: 'HappyBirthdayJustinBieber'})  
return m.mention as Mention,h.hashtag as Hashtag,t.type as Type,collect(t.tid) as tweet_ids, count( distinct t.tid) as mentionCount order by mentionCount Desc   LIMIT 3;

//8. Given a hashtag, retrieve top 3 users (author_screen_names) who have used
//the given hashtag in the tweets (tweet_type : Tweet) that they have posted.
//Sort them in decreasing order of frequencies. Your output should include the
//following:
//Hashtag – User – Tweet-ids posted by the user and containing this hashtag
//–Tweet Count

// for Graph
MATCH (a:Author)-[at:WROTE]->(t:Tweet{type:'Tweet'})-[th:HAS_HASHTAG]->(h:Hashtag{hashtag: 'MondayMotivation'})  
return a,at,t,th,h;
// for Table
MATCH (a:Author)-[at:WROTE]->(t:Tweet{type:'Tweet'})-[th:HAS_HASHTAG]->(h:Hashtag{hashtag: 'MondayMotivation'})  
return h.hashtag as Hashtag,a.author_screen_name as User,collect(t.tid) as tweet_ids, count( distinct t.tid) as tweetCount order by tweetCount Desc limit 3;

