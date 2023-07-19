---
title: bk-cmdb安装
date: 2019-3-27
updated: 2019-3-28
tags:
  - bk-cmdb
categories:
  - note
abbrlink: ca142a6
---

[github地址](https://github.com/Tencent/bk-cmdb)

* 配置java环境
```shell
cd /soft
mkdir /usr/local/java
tar xf jdk-8u131-linux-x64.tar.gz -C /usr/local/java
vim /etc/profile
JAVA_HOME=/usr/local/java/jdk1.8.0_131
export JAVA_HOME
CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export CLASSPATH
PATH=$PATH:$HOME/bin:$JAVA_HOME/bin
export PATH
```
<!--more-->
* 配置zookeeper
```shell
cd /soft
tar xf zookeeper-3.4.14.tar.gz
mv zookeeper-3.4.14 /usr/local/zookeeper
cd /usr/local/zookeeper/conf/
cp zoo_sample.cfg zoo.cfg
cd ../bin/
./zkServer.sh start #启动
ps -ef |grep zookeepe #验证
./zkCli.sh -server 127.0.0.1:2181 #验证
```

* 配置redis

```shell
cd /soft/
tar xf redis-3.2.11.tar.gz 
cd redis-3.2.11
yum install gcc -y
make
make install
./utils/install_server.sh
vim /etc/redis/6379.conf 
requirepass cmdb_cmdb #增加
/etc/init.d/redis_6379 restart
redis-cli  -a cmdb_cmdb  #验证
```

* 配置mongodb

```shell
vim /etc/yum.repos.d/mongodb.repo
	[MongoDB]
	name=MongoDB
	baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.4/x86_64/
	enabled=1
	gpgcheck=0
yum install mongodb-org -y
/etc/init.d/mongod start
mongo --port 27017 
	> use cmdb
	> db.createUser({user: "cmdb",pwd: "cmdb",roles: [ { role: "readWrite", db: "cmdb" } ]})
vim /etc/mongod.conf
	net:
	  port: 27017
	  bindIp: 0.0.0.0  #修改
/etc/init.d/mongod restart
```


* 安装cmdb

```shell
cd /soft
tar xf cmdb.tar.gz 
cd cmdb
python init.py --discovery 127.0.0.1:2181 --database cmdb --redis_ip 127.0.0.1 --redis_port 6379 --redis_pass cmdb_cmdb --mongo_ip 127.0.0.1 --mongo_port 27017 --mongo_user cmdb --mongo_pass cmdb --blueking_cmdb_url http://127.0.0.1:8083 --listen_port 8083
./start.sh 
bash ./init_db.sh
```
