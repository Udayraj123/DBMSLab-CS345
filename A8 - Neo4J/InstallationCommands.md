#### Install the dependencies
```bash
sudo -E apt-get install php7.1-dev libgmp-dev libpcre3-dev g++ make cmake libssl-dev openssl
```

#### Add Neo4j Keys
```bash
wget -O - https://debian.neo4j.org/neotechnology.gpg.key | sudo apt-key add -
echo 'deb https://debian.neo4j.org/repo stable/' | sudo tee /etc/apt/sources.list.d/neo4j.list
```

#### Install Java
```bash
sudo -E add-apt-repository ppa:webupd8team/java
sudo -E apt-get update 
sudo -E apt-get install oracle-java8-set-default
```

#### Install Neo4j
```bash
sudo apt-get install neo4j
```
