#### Install the (common) dependencies
Use `python` for python2 -
```bash
sudo -E apt-get install python3 python3-pip  php7.1-dev libgmp-dev libpcre3-dev g++ make cmake libssl-dev openssl
```
Following is referred mainly from https://neo4j.com/docs/operations-manual/current/installation/
For debian installations

#### Add Repos/Keys and Update
```bash
wget -O - https://debian.neo4j.org/neotechnology.gpg.key | sudo apt-key add -
echo 'deb https://debian.neo4j.org/repo stable/' | sudo tee /etc/apt/sources.list.d/neo4j.list
sudo -E add-apt-repository ppa:webupd8team/java
sudo -E apt-get update 
```

#### Install Java
```bash
sudo -E apt-get install oracle-java8-set-default
```

#### Install Neo4j
```bash
sudo apt-get install neo4j
```

#### (optional) Add env variable (put this line in /etc/bash.bashrc)
```bash
export NEO4J_HOME="/var/lib/neo4j";
export NEO4J_CONF="/etc/neo4j/neo4j.conf";

```

#### If JAVA_HOME is not set (usually it's set automatically after installation), you can set it as-
```bash
export JAVA_HOME="/usr/lib/jvm/java-8-oracle";
```

#### Test everything is working as expected
```bash
# Check Java is installed and accessible
java -version

# Check neo4j and its shell is installed and accessible
neo4j version
cypher-shell -v

# Check neo4j service current status (may be currently inactive)
sudo -u neo4j neo4j status
```
> Neo4j is not running

Also, service status: 
```bash
sudo service neo4j status
# Alter: sudo systemctl status neo4j
```
```console
 ● neo4j.service - Neo4j Graph Database
    Loaded: loaded (/lib/systemd/system/neo4j.service; disabled; vendor preset: enabled)
    Active: inactive (dead)
```
^It can be active already in some cases. If it is so, turn it off so that we can do some additional changes below.
```bash
sudo systemctl stop neo4j
```
We need to give it some permissions before starting it so that it runs smoothly.

#### Give permissions to neo4j's directories
```bash
# Create /var/run/neo4j if not exists
sudo test -d /var/run/neo4j || (sudo mkdir /var/run/neo4j && echo Directory created.)

sudo chown -R neo4j:neo4j /var/lib/neo4j
sudo chown -R neo4j:neo4j /var/run/neo4j
sudo chown -R neo4j:neo4j /var/log/neo4j

```

#### Starting/Stopping Neo4j
```bash
# Stop existing runs
sudo systemctl stop neo4j
# May take about 10 seconds to start sometimes-
sudo -u neo4j neo4j start
# Command to check the log 
journalctl -e -u neo4j
```
It starts the server for browser interface at http://localhost:7474/. 
You can login there with Initial *username neo4j and password also neo4j*.
All the basics you need to know are present here. It also has an awesome interactive coding tutorial under Jump into code section, do check it out after going thru the intro. 
It also starts neo4j server at bolt://localhost:7687 to which we can connect with drivers later.

#### Hello World on Cypher!
Once you've set the password above, you can login to cypher-shell with write privileges.
```bash
cypher-shell -u neo4j -p yourpassword
# Inside the shell, create your first node in Neo4j's database
CREATE (m:Movie { title:"The Matrix",released:1997 }) RETURN m;
```
```console
 +------------------------------------------------+
 | m                                              |
 +------------------------------------------------+
 | (:Movie {title: "The Matrix", released: 1997}) |
 +------------------------------------------------+ 
 1 row available after 55 ms, consumed after another 3 ms
 Added 1 nodes, Set 2 properties, Added 1 labels
```


#### Increasing maximum open files limit*
* yet to make it work...

For neo4j user only so that other functionalities of your PC are not affected.
Reference: https://neo4j.com/docs/operations-manual/current/installation/linux/
```bash
# Current limit (1024)
ulimit -n

# Edit /etc/security/limits.conf and add these two lines:
sudo subl /etc/security/limits.conf
neo4j   soft    nofile  40000
neo4j   hard    nofile  40000

# Edit /etc/pam.d/su and uncomment or add the following line:
sudo subl /etc/pam.d/su
session    required   pam_limits.so

# A restart is required for the settings to take effect.
sudo shutdown -r +0
```

#### Neo4j server in foreground mode
Type this in a new tab(Ctrl+Shift+T) 
```bash
# When Neo4j runs in console mode, logs are printed to the Terminal.
sudo -u neo4j neo4j console
# Alternative: sudo neo4j console 
```
This command also starts the neo4j web server.


#### Neo4j server in background mode(only if installed from a debian/rpm package)
```bash
# (Optional, done already in debian) 
# sudo systemctl enable neo4j

# start/restart service
sudo systemctl restart neo4j
sudo systemctl status neo4j
# Alternative: sudo service neo4j status
```
```console
 ● neo4j.service - Neo4j Graph Database
    Loaded: loaded (/lib/systemd/system/neo4j.service; disabled; vendor preset: enabled)
    Active: active (running) since Wed 2018-04-11 17:38:30 IST; 31min ago

```
```bash
sudo -u neo4j neo4j status
```

#### Python driver (use pip instead of pip3 if using python2)
Manual link : https://neo4j.com/docs/developer-manual/current/drivers/
```bash
sudo -E -H pip3 install neo4j-driver
# Some other community drivers like py2neo are also available from https://neo4j.com/developer/python/
```

#### Hello world on the driver
open the `helloNeo4j.py` file 
```bash
subl helloNeo4j.py 
```
and change the username and password to your credentials.
Then you can run -
```bash
python3 helloNeo4j.py 
```
```console
 Hello World, from node 61
```


#### Common errors
1. For `sudo -u neo4j neo4j status`, if you are still getting-
	> Neo4j is not running
	
	Refer here : https://stackoverflow.com/questions/39907051/neo4j-not-running
	and here : https://groups.google.com/forum/#!topic/neo4j/7-H8Or1PJg4

2. If you get an error having something like-
	>  Store and its lock file has been locked by another process: 

	Probably an instance has already started(say, via the web interface). You can stop it by-
	```bash
	sudo systemctl stop neo4j
	```
	If the problem still persists, you can kill the process by-
	```bash
	ps aux | grep "org.neo4j.server"
	# Get the process id (2nd column, next to 'neo4j')
	sudo kill -9 process-id
	```
	Ref: https://github.com/neo4j/neo4j/issues/10420

3.  If you get "No such file or directory" error for (sub)directories in `/var/lib/neo4j/run/`,`/var/lib/neo4j/logs`
	Then you may have to link the respective directories using `ln`.
	```bash
	sudo ln -s /var/run/neo4j /var/lib/neo4j/run
	sudo ln -s /var/log/neo4j /var/lib/neo4j/logs
	```

#### Changing password
It can be changed via the browser interface when you login for the first time( default username is neo4j and password is neo4j.)
Just for its coolness, you may use following command to open the link in default browser via terminal.
```bash
xdg-open http://localhost:7474/
```
OR you can follow the shell method-
```bash
# It can be changed as below
neo4j-admin set-initial-password yourpassword
```
Here if you get the error:
> command failed: initial password was not set because live Neo4j-users were detected.

Refer here : https://stackoverflow.com/questions/47530154/neo4j-command-failed-initial-password-was-not-set-because-live-neo4j-users-wer?rq=1

#### Further 
1. You can add aliases-
	```bash
	alias startneo4j="sudo -u neo4j neo4j status && sudo -u neo4j neo4j console";
	alias checkneo4j="sudo service neo4j status && sudo -u neo4j neo4j status";
	
	alias cypher-login="cypher-shell --debug -u neo4j -p yourpassword";
	```
2. Sublime text 2 package-
	https://github.com/kollhof/sublime-cypher

3. Some FAQ
	Taken from https://neo4j.com/blog/recap-intro-to-graph-databases-webinar-series-1/
    The neo is from Neo Technology, What does the 4j in neo4j stand for? -Anonymous
	> “For Java”. As Neo4j is written in Java and provides a native API for the JVM. Other languages can access Neo4j Databases via a RESTful server protocol. 
    How does CAP theorem apply to neo4j? -MK
	> Neo4j is not partition tolerant. Automatic, domain agnostic graph sharding is still a problem that we have to solve to scale out

    Is the traversal asynchronous? -NV
	> Right now traversals are synchronous. And so far they were fast enough. But we’ve been thinking about providing parallel traversals.

	> "There are no nulls in the nodes. If a value for some attribute is to be NULL, that attribute just won't be present in that node"