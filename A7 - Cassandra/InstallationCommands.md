#### Install the dependencies
```bash
sudo -E apt-get install php7.1-dev libgmp-dev libpcre3-dev g++ make cmake libssl-dev openssl
```

#### Add Repos/Keys and Update
```bash
echo "deb http://www.apache.org/dist/cassandra/debian 311x main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list 
curl https://www.apache.org/dist/cassandra/KEYS | sudo -E apt-key add -
sudo -E add-apt-repository ppa:webupd8team/java
sudo -E apt-get update 
```

#### Install Java
```bash
sudo -E apt-get install oracle-java8-set-default
```

#### Install Cassandra
```bash
sudo -E apt-get install cassandra
```

#### add CASSANDRA_HOME env variable (put this line in /etc/bash.bashrc)
```bash
export CASSANDRA_HOME="/var/lib/cassandra";
```

#### If JAVA_HOME is not set (usually it's set automatically after installation), you can set it as-
```bash
export JAVA_HOME="/usr/lib/jvm/java-8-oracle";
```

#### Test everything is working till now
```bash
# Check Java is installed and accessible
java -version

# Check Cassandra service is running
sudo service cassandra status

# Check Nodetool status: UN means it's Up and Normal:
sudo nodetool status

```

#### Configure Cassandra (conf is found in /etc/cassandra/ when installed using apt-get, else in the zip if you've extracted from 
```basha zip)
sudo subl /etc/cassandra/cassandra.yaml
```

#### Give permissions to data directory before starting cassandra
```bash
sudo chown -R cassandra:cassandra /var/lib/cassandra
# And if you've configured using ~/cassandra as data directory, give permission to it
# sudo chown -R cassandra:cassandra ~/cassandra

```
#### Now in a new tab(Ctrl+Shift+T) you can start the cassandra server in foreground mode
```bash
sudo -u cassandra cassandra -f
```

#### In another tab check connection
```bash
# Check cassandra connection and version
cqlsh --color --debug
```

#### Python driver (use pip instead of pip3 if using python2)
```bash
sudo -E -H pip3  install cassandra-driver
```

#### CPP and PHP DRIVER INSTALLATION (note: php driver needs cpp driver)
```bash
mkdir temp_dir; cd temp_dir;

wget http://downloads.datastax.com/cpp-driver/ubuntu/16.04/dependencies/libuv/v1.18.0/libuv_1.18.0-1_amd64.deb
wget http://downloads.datastax.com/cpp-driver/ubuntu/16.04/dependencies/libuv/v1.18.0/libuv-dev_1.18.0-1_amd64.deb
wget http://downloads.datastax.com/cpp-driver/ubuntu/16.04/cassandra/v2.8.1/cassandra-cpp-driver_2.8.1-1_amd64.deb
wget http://downloads.datastax.com/cpp-driver/ubuntu/16.04/cassandra/v2.8.1/cassandra-cpp-driver-dev_2.8.1-1_amd64.deb
```

> Note: If you have node/npm installed, the libuv library may cause an error in the dpkg command like
> trying to overwrite '/usr/lib/x86_64-linux-gnu/libuv.so.1.0.0', which is also in package libuv 1.18.0-1
> If you don't need libuv, You may uninstall it(which'd also remove node) by `sudo -E apt-get remove libuv libuv-dev`
> Else on assumption that the two packages actually have same content in the .so file,
> you can add the --force-overwrite flag in the dpkg commands

#### Also, if you've run below commands once before, you should run `sudo -E apt --fix-broken install`
```bash
sudo dpkg -i libuv_1.18.0-1_amd64.deb
sudo dpkg -i libuv-dev_1.18.0-1_amd64.deb
sudo dpkg -i cassandra-cpp-driver_2.8.1-1_amd64.deb
sudo dpkg -i cassandra-cpp-driver-dev_2.8.1-1_amd64.deb

sudo -E pecl install cassandra
sudo sh -c 'echo "extension=cassandra.so" > /etc/php/7.1/mods-available/cassandra.ini'
sudo phpenmod cassandra
```

#### Test Commands and their outputs
```bash
php -i | grep -A 10 -e "^cassandra$"
```

> Cassandra support => enabled
> C/C++ driver version => 2.8.1
> Persistent Clusters => 0
> Persistent Sessions => 0
> 
> Directive => Local Value => Master Value
> cassandra.log => cassandra.log => cassandra.log
> cassandra.log_level => ERROR => ERROR

```bash
sudo service cassandra status
```

> ● cassandra.service - LSB: distributed storage system for structured data
>    Loaded: loaded (/etc/init.d/cassandra; generated; vendor preset: enabled)
>    Active: active (exited) since Wed 2018-03-28 15:59:47 IST; 1h 2min ago
>      Docs: man:systemd-sysv-generator(8)
>     Tasks: 0 (limit: 4915)
>    CGroup: /system.slice/cassandra.service
> 
> Warning: Journal has been rotated since unit was started. Log output is incomplete or unavailable.

```bash
sudo nodetool status
```
> Datacenter: datacenter1
> =======================
> Status=Up/Down
> |/ State=Normal/Leaving/Joining/Moving
> --  Address    Load       Tokens       Owns (effective)  Host ID                               Rack
> UN  127.0.0.1  159.98 KiB  256          100.0%            60f92719-4241-47b6-ade1-78f30283d8b8  rack1

#### Further you can add aliases-
```bash
alias startcass="sudo service cassandra status && sudo -u cassandra cassandra -f";
alias checkcass="sudo service cassandra status && sudo nodetool status";
alias cqlshell="cqlsh --debug --color --request-timeout=30";
```