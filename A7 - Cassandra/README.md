### Cassandra Model for Twitter dataset

## Languages and Packages used
Note: All the details of installation commands is in the file 'latestCommandsMar2018.txt' 

### Ubuntu packages
php7.1-dev libgmp-dev libpcre3-dev g++ make cmake libssl-dev openssl
oracle-java8-set-default
cassandra 3.11.0 (from apache deb sources)
cqlsh 5.0.1
apache2


### Php (7.1)
cassandra-cpp-driver
cassandra (from pecl)

### Python3 (3.6.3)
pip3: 9.0.1
numpy: 1.14.1
pandas: 0.21.0
cassandra-driver (for cassandra 3.11.0)

## Description of files/folders

#### workshop_dataset
The folder containing all the json data. Each file is named by a date and it contains about 1000 public tweets captured on that date.
#### schema_model.pdf
Contains the Schema creation statements of the Cassandra Model implemented.

#### Prepare DB.pynb
This code handles the loading of data from json. Then it does handling different data types such as lists,maps and nulls, type conversions, etc i.e. data is transformed to lists that can be readily inserted. Thenafter the INSERT queries are performed here.

#### Index.php
This file gives the web interface to enter data, runs the appropriate SELECT queries and lastly displays them in a simple table.
