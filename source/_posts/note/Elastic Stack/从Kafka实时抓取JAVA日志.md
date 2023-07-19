---
title: 从Kafka实时抓取JAVA日志
date: 2021-2-12
tags:
  - Elasticsearch
  - elk
  - ZooKeeper
  - Kafka
categories:
  - note
abbrlink: 5be08c97
---

## 前言
本篇博客完整的记录了zk及kafka完整安装过程，并协同开发将java应用日志，直接输出至kafka集群，随后通过logstash的kafka input插件进行主题消费，并通过正则进行数据结构化，最后输出到es集群（es集群通过k8s采用eck模式进行安装），数据结果则使用kibaka进行展示，默认关闭selinux及防火墙，系统优化已提前做完；

## 部署环境介绍
平台|IP|主机名|ECK版本|ZK版本|Kafka版本
-|-|-|-|-|-
CentOS Linux release 7.7.1908|192.168.6.10|DEVOPSSRV01|ELK:7.10.1|3.6.2	2.5.0
CentOS Linux release 7.7.1908|192.168.6.39|DBSRV01|ELK:7.10.1|3.6.2|2.5.0
CentOS Linux release 7.7.1908|192.168.6.45|TSSRV02|ELK:7.10.1|3.6.2|2.5.0

## ZooKeeper集群安装与配置
### 安装并配置JDK1.8环境
```shell
#安装jdk1.8.0_261
[root@DEVOPSSRV01 java]# pwd
/opt/java
[root@DEVOPSSRV01 java]# ls
jdk1.8.0_261  jdk-8u261-linux-x64.tar.gz
#配置jdk、zk、kafka环境变量
[root@DEVOPSSRV01 ~]# cat /etc/profile
# /etc/profile
# Java Environment Config
JAVA_HOME=/opt/java/jdk1.8.0_261
JRE_HOME=/opt/java/jdk1.8.0_261/jre
CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib
PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin:/usr/local/kafka-2.5.0/bin:/usr/local/zk-3.6.2/bin
export PATH JAVA_HOME JRE_HOME CLASSPATH
```

### 下载并安装zk
zk下载地址：[Apache ZooKeeper™ Releases](https://zookeeper.apache.org/releases.html)
```shell
#解压二进制安装文件至/usr/local
[root@DEVOPSSRV01 soft]# tar xzvf apache-zookeeper-3.6.2-bin.tar.gz -C /usr/local/
#切换至通用安装路径
[root@DEVOPSSRV01 soft]# cd /usr/local/
#修改zk文件夹名称
[root@DEVOPSSRV01 local]# mv apache-zookeeper-3.6.2-bin /usr/local/zk-3.6.2
```

### zk集群配置
```shell
# 默认情况下只需要对dataDir进行配置，新增集群配置信息即可；

[root@DEVOPSSRV01 ~]# cd /usr/local/zk-3.6.2/conf/
[root@DEVOPSSRV01 conf]# cp zoo_sample.cfg zoo.cfg
[root@DEVOPSSRV01 conf]# vim zoo.cfg
#修改数据文件目录
dataDir=/usr/local/zk-3.6.2/data
...
#调整集群配置
server.0=192.168.6.10:2888:3888
server.1=192.168.6.45:2888:3888
server.2=192.168.6.39:2888:3888
```


### zoo.cfg配置文件详解
```
# 通信心跳数，Zookeeper服务器与客户端心跳时间，单位毫秒Zookeeper使用的基本时间，服务器之间或客户端与服务器之间维持心跳的时间间隔，也就是每个tickTime时间就会发送一个心跳，时间单位为毫秒。 它用于心跳机制，并且设置最小的session超时时间为两倍心跳时间。（session的最小超时时间是2*tickTime）
tickTime=2000
# LF初始通信时限 集群中的Fo1lower跟随者服务器与Leader领导者服务器之间初始连接时能容忍的最多心跳数（tickTime的数量），用它来限定集群中的Zookeeper服务器连接到Leader的时限。
initLimit=10
# LF同步通信时限 集群中Leader与Fo1lower之间的最大响应时间单位，假如响应超过syncLimit*tickTime，Leader认为Fo11wer死掉，从服务器列表中删除Fo1lwer。
syncLimit=5
# 数据文件目录+数据持久化路径 主要用于保存Zookeeper中的数据。
dataDir=/usr/local/zk-3.6.2/data
# 客户端连接端口 监听客户端连接的端口。
clientPort=2181
# 客户端连接的最大连接数
#maxClientCnxns=60
# 要保留在dataDir中的快照数
#autopurge.snapRetainCount=3
# 清除任务间隔（小时）
# 设置为“0”以禁用自动清除功能
#autopurge.purgeInterval=1
#server.x：x表示一个数字，这个数字表示第几个服务器，配置在myid的文件，3888：选举leader使用，2888：集群内机器通讯使用（Leader监听此端口）
server.0=192.168.6.10:2888:3888
server.1=192.168.6.45:2888:3888
server.2=192.168.6.39:2888:3888
```

### zk集群同步
以上操作全部在三台服务器上进行，可使用scp进行快速多机拷贝，拷贝完成后，对myid进行修改，确保与zoo.cfg中server.x保持一直，并唯一；
```shell
#DEVOPSSRV01主机的myid：0
[root@DEVOPSSRV01 data]# cat myid 
0
[root@DEVOPSSRV01 data]# pwd
/usr/local/zk-3.6.2/data

#TSSRV02主机的myid：1
[root@TSSRV02 data]# cat myid 
1
[root@TSSRV02 data]# pwd
/usr/local/zk-3.6.2/data

#DBSRV01主机的myid：2
[root@DBSRV01 data]# cat myid 
2
[root@DBSRV01 data]# pwd
/usr/local/zk-3.6.2/data
```

### zk集群管理
#### 启动集群
```shell
#三台机器共同执行zkServer.sh start
#TSSRV02
[root@TSSRV02 logs]# zkServer.sh start
ZooKeeper JMX enabled by default
Using config: /usr/local/zk-3.6.2/bin/../conf/zoo.cfg
Starting zookeeper ... STARTED
#DBSRV01
[root@DBSRV01 logs]# zkServer.sh start
ZooKeeper JMX enabled by default
Using config: /usr/local/zk-3.6.2/bin/../conf/zoo.cfg
Starting zookeeper ... STARTED
#DEVOPSSRV01
[root@DEVOPSSRV01 logs]# zkServer.sh start
ZooKeeper JMX enabled by default
Using config: /usr/local/zk-3.6.2/bin/../conf/zoo.cfg
Starting zookeeper ... STARTED
```

#### 查看集群状态
```shell
#三台机器共同执行zkServer.sh status
#TSSRV02主机角色为follower
[root@TSSRV02 logs]# zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /usr/local/zk-3.6.2/bin/../conf/zoo.cfg
Client port found: 2181. Client address: localhost. Client SSL: false.
Mode: follower

#DBSRV01主机角色为leader，由于DBSRV01的myid是2，权重大，所以它是leader角色
[root@DBSRV01 logs]# zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /usr/local/zk-3.6.2/bin/../conf/zoo.cfg
Client port found: 2181. Client address: localhost. Client SSL: false.
Mode: leader

#DEVOPSSRV01主机角色为DEVOPSSRV01
[root@DEVOPSSRV01 logs]# zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /usr/local/zk-3.6.2/bin/../conf/zoo.cfg
Client port found: 2181. Client address: localhost. Client SSL: false.
Mode: follower
```

#### 停止与重启指令
```shell
#停止
zkServer.sh stop
#重启
zkServer.sh restart
```

## Kafka集群安装与配置

### 下载并安装kafka（免编译）
kafka下载地址：[DOWNLOAD KAFKA](https://kafka.apache.org/downloads)
```shell
#解压至指定目录
[root@DEVOPSSRV01 soft]# tar xzvf kafka_2.12-2.5.0.tgz -C /usr/local/ && cd /usr/local/
#重命名
[root@DEVOPSSRV01 local]# mv kafka_2.12-2.5.0 /usr/local/kafka-2.5.0
#切换到kafaka二进制资源目录
[root@DEVOPSSRV01 soft]# cd kafka-2.5.0/
#创建日志目录
[root@DEVOPSSRV01 local]# mkdir -pv /var/log/kafka
#文件结构
[root@DEVOPSSRV01 kafka-2.5.0]# ls
bin  config  libs  LICENSE  logs  NOTICE  site-docs
[root@DEVOPSSRV01 kafka-2.5.0]# pwd
/usr/local/kafka-2.5.0
```

### kafka集群配置
```shell
#切换至kafka配置文件目录
[root@DEVOPSSRV01 ~]# cd /usr/local/kafka-2.5.0/config/
#对broker的配置文件server.properties进行调整
[root@DEVOPSSRV01 config]# vim server.properties
broker.id=0
listeners=PLAINTEXT://192.168.6.10:9092
log.dirs=/var/log/kafka
zookeeper.connect=192.168.6.10:2181,192.168.6.39:2181,192.168.6.45:2181
```

### broker的配置文件server.properties详解
```
############################# Server Basics #############################
#每一个broker在集群中的唯一标示，要求是正数
broker.id=0

############################# Socket Server Settings #############################
#服务端监听地址，可采用0.0.0.0，但如果服务器上部署了docker集群，建议绑定固定网卡IP
listeners=PLAINTEXT://192.168.6.10:9092

#处理网络请求的线程数量，也就是接收消息的线程数。
#接收线程会将接收到的消息放到内存中，然后再从内存中写入磁盘
num.network.threads=3

#消息从内存中写入磁盘是时候使用的线程数量。
#用来处理磁盘IO的线程数量
num.io.threads=8

#发送套接字的缓冲区大小
socket.send.buffer.bytes=102400

#接受套接字的缓冲区大小
socket.receive.buffer.bytes=102400

#请求套接字的缓冲区大小
socket.request.max.bytes=104857600


############################# Log Basics #############################
#kafka运行日志存放的路径
log.dirs=/var/log/kafka

#topic在当前broker上的分片个数
num.partitions=1

#我们知道segment文件默认会被保留7天的时间，超时的话就
#会被清理，那么清理这件事情就需要有一些线程来做。这里就是
#用来设置恢复和清理data下数据的线程数量
num.recovery.threads.per.data.dir=1

############################# Internal Topic Settings  #############################
# The replication factor for the group metadata internal topics "__consumer_offsets" and "__transaction_state"
# For anything other than development testing, a value greater than 1 is recommended to ensure availability such as 3.
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1

############################# Log Flush Policy #############################
#上面我们说过接收线程会将接收到的消息放到内存中，然后再从内存
#写到磁盘上，那么什么时候将消息从内存中写入磁盘，就有一个
#时间限制（时间阈值）和一个数量限制（数量阈值），这里设置的是
#数量阈值，下一个参数设置的则是时间阈值。
#partion buffer中，消息的条数达到阈值，将触发flush到磁盘。
#log.flush.interval.messages=10000

#消息buffer的时间，达到阈值，将触发将消息从内存flush到磁盘，
#单位是毫秒。
#log.flush.interval.ms=1000

############################# Log Retention Policy #############################
#segment文件保留的最长时间，默认保留7天（168小时），
#超时将被删除，也就是说7天之前的数据将被清理掉。
log.retention.hours=720

#topic每个分区的最大文件大小，一个topic的大小限制 = 分区数*log.retention.bytes 。-1没有大小限制
#log.retention.bytes和log.retention.minutes任意一个达到要求，都会执行删除，会被topic创建时的指定参数覆盖
#log.retention.bytes=1073741824

#日志文件中每个segment的大小，默认为1G
log.segment.bytes=1073741824

#上面的参数设置了每一个segment文件的大小是1G，那么
#就需要有一个东西去定期检查segment文件有没有达到1G，
#多长时间去检查一次，就需要设置一个周期性检查文件大小
#的时间（单位是毫秒）
log.retention.check.interval.ms=300000

############################# Zookeeper #############################
#zookeeper集群的地址，可以是多个，多个之间用逗号分割
#hostname1:port1,hostname2:port2,hostname3:port3
zookeeper.connect=192.168.6.10:2181,192.168.6.39:2181,192.168.6.45:2181

#zookeeper链接超时时间
#单位是毫秒。
zookeeper.connection.timeout.ms=18000

############################# Group Coordinator Settings #############################
#当Consumer Group新增或减少Consumer时，重新分配Topic Partition的延迟时间
group.initial.rebalance.delay.ms=0
```

### kafka集群同步
以上操作全部在三台服务器上进行，可使用scp进行快速多机拷贝，拷贝完成后，对broker.id、listeners、log.dirs、zookeeper.connect关键参数进行修改；
```shell
#修改完成后切换至配置文件目录
[root@TSSRV02 ~]# cd /usr/local/kafka-2.5.0/config
#使用grep命令进行配置过滤和比对，如下图
[root@TSSRV02 config]# egrep -v '^#|^$' server.propertie
```

### kafka集群管理
```shell
#非交互式启动集群
bin/kafka-server-start.sh -daemon config/server.properties
#停止kafka集群
bin/kafka-server-stop.sh stop
#查看主题列表
kafka-topics.sh --zookeeper 0.0.0.0:2181 --list
#创建主题logStash，有3个分区，1个副本
kafka-topics.sh --zookeeper 0.0.0.0:2181 --create --topic logStash --replication-factor 1 --partitions 3
#查看指定topic详情
kafka-topics.sh --zookeeper 0.0.0.0:2181 --describe --topic logStash
#查看某一topic数据
kafka-console-consumer.sh --bootstrap-server 0.0.0.0:9092 --topic logStash --from-beginning
##查看当前消费者
kafka-consumer-groups.sh --bootstrap-server 0.0.0.0:9092 --list
##查看指定消费者消费信息，其中依次展示group名称、消费的topic名称、partition id、consumer group最后一次提交的offset、最后提交的生产消息offset、消费offset与生产offset之间的差值、当前消费topic-partition的group成员id(不一定包含hostname)
kafka-consumer-groups.sh --bootstrap-server 0.0.0.0:9092 --describe --group logstashSZZT

```

## Logstash的安装与配置
### 安装
配置好yum源后安装即可。

### java样本数据分析与正则编写
日志样本如下：
```
gateway:10.244.1.207:10000 2021-01-27 16:15:12.845 INFO main c.a.n.c.c.i.CacheData.addListener [fixed-nacos-headless.nacos-production.svc_8848-a8522218-4630-4adc-ab9f-5bb725fb9866] [a dd-listener] ok, tenant=a8522218-4630-4adc-ab9f-5bb725fb9866, dataId=router.json, group=DEFAULT_GROUP, cnt=1
```

正则分拆:
```
APP [a-zA-Z]+-?[a-zA-Z]+
IP (?<![0-9])(?:(?:[0-1]?[0-9]{1,2}|2[0-4][0-9]|25[0-5])[.](?:[0-1]?[0-9]{1,2}|2[0-4][0-9]|25[0-5])[.](?:[0-1]?[0-9]{1,2}|2[0-4][0-9]|25[0-5])[.](?:[0-1]?[0-9]{1,2}|2[0-4][0-9]|25[0-5]))(?![0-9])
PORT \b(?:[1-9][0-9]*)\b
TOMCAT_DATESTAMP 20(?>\d\d){1,2}-(?:0?[1-9]|1[0-2])-(?:(?:0[1-9])|(?:[12][0-9])|(?:3[01])|[1-9]) (?:2[0123]|[01]?[0-9]):?(?:[0-5][0-9])(?::?(?:(?:[0-5]?[0-9]|60)(?:[:.,][0-9]+)?))
LOG_LEVEL ([Aa]lert|ALERT|[Tt]race|TRACE|[Dd]ebug|DEBUG|[Nn]otice|NOTICE|[Ii]nfo|INFO|[Ww]arn?(?:ing)?|WARN?(?:ING)?|[Ee]rr?(?:or)?|ERR?(?:OR)?|[Cc]rit?(?:ical)?|CRIT?(?:ICAL)?|[Ff]atal|FATAL|[Ss]evere|SEVERE|EMERG(?:ENCY)?|[Ee]merg(?:ency)?)\s?
THREAD \S+
```

### 导入java_patterns规则库
```shell
[root@DEVOPSSRV01 logstash]# cd /usr/share/logstash/patterns/
[root@DEVOPSSRV01 patterns]# cat java_patterns 
#JAVA LOGS PATTTERNS
APP [a-zA-Z]+-?[a-zA-Z]+
IP (?<![0-9])(?:(?:[0-1]?[0-9]{1,2}|2[0-4][0-9]|25[0-5])[.](?:[0-1]?[0-9]{1,2}|2[0-4][0-9]|25[0-5])[.](?:[0-1]?[0-9]{1,2}|2[0-4][0-9]|25[0-5])[.](?:[0-1]?[0-9]{1,2}|2[0-4][0-9]|25[0-5]))(?![0-9])
PORT \b(?:[1-9][0-9]*)\b
TOMCAT_DATESTAMP 20(?>\d\d){1,2}-(?:0?[1-9]|1[0-2])-(?:(?:0[1-9])|(?:[12][0-9])|(?:3[01])|[1-9]) (?:2[0123]|[01]?[0-9]):?(?:[0-5][0-9])(?::?(?:(?:[0-5]?[0-9]|60)(?:[:.,][0-9]+)?))
LOG_LEVEL ([Aa]lert|ALERT|[Tt]race|TRACE|[Dd]ebug|DEBUG|[Nn]otice|NOTICE|[Ii]nfo|INFO|[Ww]arn?(?:ing)?|WARN?(?:ING)?|[Ee]rr?(?:or)?|ERR?(?:OR)?|[Cc]rit?(?:ical)?|CRIT?(?:ICAL)?|[Ff]atal|FATAL|[Ss]evere|SEVERE|EMERG(?:ENCY)?|[Ee]merg(?:ency)?)\s?
THREAD \S+
MESSAGE .*
```

### 导入java_log.conf配置文件
```shell
[root@DEVOPSSRV01 conf.d]# pwd
/etc/logstash/conf.d
[root@DEVOPSSRV01 conf.d]# cat java_log.conf
input {
  kafka {
    bootstrap_servers => "192.168.6.10:9092,192.168.6.39:9092,192.168.6.45:9092"
    topics => ["logStash"]
    consumer_threads => 3
    decorate_events => true
    auto_offset_reset => "earliest"
    client_id => "logstash610"
    group_id => "logstashSZZT"
    value_deserializer_class => "org.apache.kafka.common.serialization.ByteArrayDeserializer"
    key_deserializer_class => "org.apache.kafka.common.serialization.ByteArrayDeserializer"
  }
}

filter {
  grok {
    patterns_dir => ["/usr/share/logstash/patterns"]
    match => { "message" => "%{APP:app}:%{IP:ip}:%{PORT:port} %{TOMCAT_DATESTAMP:tomcat_datestamp} %{LOG_LEVEL:log_level} %{THREAD:thread} %{MESSAGE:message}" }
    overwrite => [ "message" ]
  }
  date {
    match => [ "tomcat_datestamp", "yyyy-MM-dd HH:mm:ss.SSS" ]
    target => "@timestamp"
  }
  ruby {
    code => "event.set('timestamp', event.get('@timestamp').time.localtime + 8*60*60)"
  }
  mutate {
    convert => ["timestamp", "string"]
    gsub => [ "message", "\r", "" ]
    gsub => ["timestamp", "T([\S\s]*?)Z", ""]
    gsub => ["timestamp", "-", "."]
  }
}

output {
    elasticsearch {
    hosts => ["https://192.168.6.10:30679"] 
    ssl => true
    cacert => "/data/share/elastic-pv/http-certs/tls.crt"
    user => "elastic"
    index => "unifed-auth-center-%{timestamp}"
    password => "fWX7545K62Kr40Q0KOmT2GlD"
    ssl_certificate_verification => false
    }
}
```

### 重启logstash
日志如无ERROR级别的日志，表示数据已开始向ES导入，随后请登录kibana查看数据情况
```shell
[root@DEVOPSSRV01 logstash]# systemctl restart logstash.serivce
[root@DEVOPSSRV01 logstash]# tail -f /var/log/logstash/logstash-plain.log
```
### 登录kibana创建索引查看数据
