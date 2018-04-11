<div align="center">
	<?php
	function fetchArray($inFile){
		$all_cols=['author', 'author_id', 'author_profile_image', 'author_screen_name', 'hashtags', 'keywords_processed_list', 'lang', 'like_count', 'location', 'media_list', 'mentions', 'quote_count', 'quoted_source_id', 'reply_count', 'replyto_source_id', 'retweet_count', 'retweet_source_id', 'sentiment', 'tid', 'tweet_text', 'tweet_date', 'tweet_datetime', 'type', 'url_list', 'verified' ];
		$normal_cols_str='author_screen_name,author,tid,tweet_text,location,lang,tweet_datetime';
		$cols1='hashtag,location,location_count';
		$cols2='hashtag,mention,count(*) as pair_count';
		return array(
			'query01'=> "select $cols1 from twitterdb.locations_by_hashtag where hashtag = ?",
			'query02'=> "select $cols2 from twitterdb.hashtag_mentions where tweet_date = ? group by hashtag,mention",
			);
	// if(is_file($inFile)){
	// 	return include $inFile;
	// }
	// else return False;
	}

	function printRow($row,$header=0){
		echo "<tr>";
		if($header==1){
			foreach ($row as $k=>$r)
				echo "<th> $k </th>";
		}
		else{
			foreach ($row as $k=>$r)
				echo "<td> $r </td>";
		}
		echo "</tr>";
	}
// Printing stuff
	function printResult($result){
		echo "<table border=\"1\">";
		printRow($result[0],1);
		foreach ($result as $row)
			printRow($row,0);
		echo "</table>";
	}

	?>
	<script type="text/javascript">
		function setVal(text){
			document.getElementById('inp').value=text;
		}
	</script>
	<form action="" method="post">
		
		<label> Your input query text: <input id="inp" type="text" name="query" required placeholder="Your query here.."></label>
		<br>
		<br>
		<!-- <label> <input type="radio" name="type" required value="query1" checked="checked"> Query 1</label> -->
		<label> <input type="radio" name="type" required onclick="setVal('BoxingDay')" value="query01"> Query 1</label>
		<label> <input type="radio" name="type" required  onclick="setVal('2018-01-15')" value="query02"> Query 2</label>
		<br>
		<br>
		<input type="submit" value="Submit">
	</form>

	<hr>
	<hr>

	<?php
/*
By default, Cassandra uses 7000 for cluster communication (7001 if SSL is enabled), 9042 for native protocol clients, and 7199 for JMX. The internode communication and native protocol ports are configurable in the Cassandra Configuration File. The JMX port is configurable in cassandra-env.sh (through JVM options). All ports are TCP.
*/
if(isset($_POST['query'])){
	$query=$_POST['query'];
	$type=$_POST['type'];
	$cluster = Cassandra::cluster()
	->withContactPoints('localhost')
	->withPort(9042)
	->build();
	$session = $cluster->connect();
	echo "<pre>(Connection established with avg ".$session->metrics()['requests']['mean']." requests...)</pre>";
	if($type == 'query5'){
		if(strtotime($query)==false){
			echo "Invalid date '$query, try in format: 'yyyy-mm-dd'<br>";
			return;
		}
		print_r(strtotime($query));
		$query = new Cassandra\Timestamp(strtotime($query));
		// print_r($query);
	}

	$all_queries=fetchArray('/home/udayraj/Downloads/coding/DBMSLab/A7 - Cassandra/select_queries.php');
	$prep_query = $session->prepare($all_queries[$type]);
	echo "<h4>Prepared Query Used:</h4> <pre>".$all_queries[$type]."</pre>";
	$result = $session->execute($prep_query, ['arguments' => [$query], 'page_size'=>200]);
	// $result = $session->execute($prep_query);
	// Invalid unset value actually means the query was invalid and not enough vars were provided : https://www.datastax.com/dev/blog/datastax-java-driver-2-2-0-rc1-released
	// $result = $session->execute('SELECT keyspace_name, table_name FROM system_schema.tables limit 5;');
	echo "<h4>Output(".$result->count()." rows):</h4>";
	echo "<pre>";
	if($result->count() > 0)
		printResult($result);
	else
		echo "<b>Empty result</b>";
	echo "</pre>";

	$session->close();
	echo "<br>";
	echo "<pre>(Connection closed...)</pre>";
}
?>
</div>