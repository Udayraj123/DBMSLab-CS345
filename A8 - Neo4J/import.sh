# Stop existing runs
sudo systemctl stop neo4j
sudo -E rm -rf /var/lib/neo4j/data/databases/graph.db
sudo -E mkdir /var/lib/neo4j/data/databases/graph.db
sudo chown neo4j:neo4j -R /var/lib/neo4j/data/databases/ 
# sudo -E neo4j-admin import \
sudo -E -u neo4j neo4j-import \
--into /var/lib/neo4j/data/databases/graph.db \
--nodes:Author csvs/Author.csv \
--nodes:Tweet csvs/Tweet.csv \
--relationships:WROTE csvs/WROTE.csv
# --relationships:REPLY_TO csvs/REPLY_TO.csv \
# --multiline-fields true

# May take about 10 seconds to start sometimes-
sudo -u neo4j neo4j start

