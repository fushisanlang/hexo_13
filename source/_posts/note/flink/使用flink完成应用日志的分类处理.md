---
title: 使用flink完成应用日志的分类处理
date: 2023-2-6
tags:
  - flink
  - kafka
  - zookeeper
  - filebeat
  - elk
categories:
  - note
abbrlink: 430a2835
---

# 使用flink完成应用日志的分类处理
## 需求说明
公司日志使用的 `elfk` 架构，日志基本没用进行清理，直接存入到了 `es` 中。
这样使得 `es` 的数据量极大。
而且因为不同类型的日志都在一起，有些日志是有意义的，包含了交易信息，想要长久保留。但是有些非业务日志是不需要长久保留的，但是由于都在 `es` 的相同 `index` 中，清理起来很不方便。
还有就是，由于某些原因，可能导致日志中有敏感数据，容易造成信息泄漏。
基于上述几个原因，决定引入一个日志处理机制，可以将应用日志进行分类处理，并且在需要的时候可以对日志内容进行脱敏处理。

## 工具选择
在上述需求基础上。设想了两种处理模式。
1. 通过工具，定时处理 `es` 中的数据。
2. 通过工具，直接在 `kafka` 与 `es` 之间进行流处理。
第一种方法安全性更高，但是滞后性比较大，所以经过研究，决定使用第二种方法。

经过调研，找到如下几个工具。
软件|官网|优点|缺点
-|-|-|-
flink|[官网地址](https://flink.apache.org/)|性能好，可以无限扩展集群|需要额外安装，学习成本高
filebeat|[官网地址](https://www.elastic.co/cn/beats/filebeat)|配置简单，使用方便|功能简单，没有集群化，修改配置麻烦
logstash|[官网地址](https://www.elastic.co/cn/logstash/)|功能丰富，系统中已经在使用|资源开销大


经过研究，最终决定试用 `flink` 看看能否满足需求。

## 测试环境说明
系统版本|cpu|mem|ip
-|-|-|-
ubuntu 22.04.1 LTS x86_64|2C|4G|10.13.13.111


## 环境搭建
### 安装java
官网推荐使用 `java-11` ，我这里装的 `java-8` 也能用。
可以去下载 `jdk` 包，或者直接安装 `open-jdk` 。
```shell
# 安装openjdk
apt-get install openjdk-8-jdk
```

### 单机安装zk
```shell
# 由于是测试环境，所以这里使用单机版。生产环境应配置集群。
wget 'https://dlcdn.apache.org/zookeeper/zookeeper-3.8.1/apache-zookeeper-3.8.1-bin.tar.gz'
tar xf apache-zookeeper-3.8.1-bin.tar.gz
cp -pr apache-zookeeper-3.8.1-bin /usr/local/zk

cd /usr/local/zk
cd conf
cp zoo_sample.cfg zoo.cfg
cd ../bin/
./zkServer.sh start
./zkServer.sh status
```

### 单机安装kafka
```shell
# 由于是测试环境，所以这里使用单机版。生产环境应配置集群。

wget https://downloads.apache.org/kafka/3.3.2/kafka_2.13-3.3.2.tgz
tar xf kafka_2.13-3.3.2.tgz 
cp -pr kafka_2.13-3.3.2 /usr/local/kafka
cd /usr/local/kafka
cd conf
vim server.properties
  zookeeper.connect=10.13.13.111:2181 #修改zk配置
  listeners=PLAINTEXT://10.13.13.111:9092 #修改监听端口

cd bin/

./zookeeper-server-stop.sh  # 关闭之前启动的zk
nohup ./zookeeper-server-start.sh ../config/zookeeper.properties  & #启动zk
nohup ./kafka-server-start.sh ../config/server.properties & #启动kafka

```


### 测试kafka
```shell
cd /usr/local/kafka/bin

# 在本机创建一个topic，名称是test，副本数量为1，分区数量为1
./kafka-topics.sh --create --bootstrap-server 10.13.13.111:9092 --replication-factor 1 --partitions 1 --topic test

#查看本机的topic
./kafka-topics.sh --list --bootstrap-server 10.13.13.111:9092

#发送消息到test
./kafka-console-producer.sh --broker-list 10.13.13.111:9092 --topic test
>aaa
>bbb
>ccc

#开启新的终端，进行读取消息测试，“--from-beginning”表示从开头读取
./kafka-console-consumer.sh --bootstrap-server 10.13.13.111:9092 --topic test --from-beginning
aaa
bbb
ccc
```

### 安装flink
```shell
# 由于是测试环境，所以这里使用单机版。生产环境应配置集群。
wget 'https://dlcdn.apache.org/flink/flink-1.16.1/flink-1.16.1-bin-scala_2.12.tgz' 
tar xf flink-1.16.1-bin-scala_2.12.tgz
cp -pr  flink-1.16.1   /usr/local/flink
cd  /usr/local/flink
./start-cluster.sh 
#默认会启动8080端口作为web端口，如果端口被占用会顺延。
#通过浏览器打开端口就能看见flink监控界面。
 ```


### 搭建模拟日志生成程序

```shell
vim /tmp/log_test.py # 将日志生成程序代码写入该文件，具体内容如下。
python /tmp/log_test.py & # 启动脚本。该脚本会每秒钟生产一条模拟日志并写入/tmp/1.log，日志内容如下：
# 2023-02-06 15:33:06,350 - func4 - ERROR - Life is a horse, and either you ride it or it rides you.
```

**日志生成程序代码：**
```python
import logging
import random
import time
logging.basicConfig(level=logging.INFO,   filename="/tmp/1.log",
                        format = '%(asctime)s - %(funcName)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

logList=["To be both a speaker of words and a doer of deeds.","Variety is the spice of life.","Bad times make a good man.","There is no royal road to learning.","Doubt is the key to knowledge.","The greatest test of courage on earth is to bear defeat without losing heart.","A man's best friends are his ten fingers.","Only they who fulfill their duties in everyday matters will fulfill them on great occasions.","The shortest way to do many things is to only one thing at a time.","Sow nothing, reap nothing.","Life is real, life is earnest.","Life would be too smooth if it had no rubs in it.","Life is the art of drawing sufficient conclusions form insufficient premises.","Life is fine and enjoyable, yet you must learn to enjoy your fine life.","Life is but a hard and tortuous journey.","Life is a horse, and either you ride it or it rides you.","Life is a great big canvas, and you should throw all the paint on it you can.","Life is like music. It must be composed by ear, feeling and instinct, not by rule.","Life is painting a picture, not doing a sum.","The wealth of the mind is the only wealth.","You can't judge a tree by its bark.","Sharp tools make good work.","Wasting time is robbing oneself.","Nurture passes nature.","There is no garden without its weeds.","A man is only as good as what he loves.","Wealth is the test of a man's character.","The best hearts are always the bravest.","One never lose anything by politeness.","There's only one corner of the universe you can be sure of improving, and that's your own self.","The world is like a mirror: Frown at itand it frowns at you; smile, and it smiles too.","Death comes to all, but great achievements raise a monument which shall endure until the sun grows old.","The reason why a great man is great is that he resolves to be a great man.","Suffering is the most powerful teacher of life.","A bosom friend afar brings a distant land near.","A common danger causes common action.","A contented mind is a continual / perpetual feast.","A fall into the pit, a gain in your wit.","A guest should suit the convenience of the host.","A letter from home is a priceless treasure.","All rivers run into the sea.","All time is no time when it is past.","An apple a day keeps the doctor away.","As heroes think, so thought Bruce.","A young idler, an old beggar.","Behind the mountains there are people to be found.","Bad luck often brings good luck.","Business is business.","Clumsy birds have to start flying early.","Do one thing at a time, and do well."]

def func1(logStr):
    logger.info(logStr)
def func2(logStr):
    logger.debug(logStr)
def func3(logStr):
    logger.warning(logStr)
def func4(logStr):
    logger.error(logStr)
while True:
    a=random.randint(0,49)
    b=random.randint(0,3)
    if b == 0:
        func1(logList[a])
    elif b == 1:
        func2(logList[a])
    elif b==3:
        func3(logList[a])
    else:
        func4(logList[a])
    time.sleep(1)
```


### 安装filebeat
 ```shell
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get install apt-transport-https
echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-8.x.list
sudo apt-get update && sudo apt-get install filebeat
sudo systemctl enable filebeat
```


### 配置filebeat
```shell
cd /etc/filebeat
vim filebeat.yml 
```

```yml
#只列出基本配置
#输入配置
filebeat.inputs:
- type: filestream
  id: err-log
  enabled: true
  paths:
    - /tmp/1.log

#输出配置
output.kafka:
  hosts: ["10.13.13.111:9092"]
  topic: 'log_104'  #将日志输出到10.13.13.111:9092的log_104topic

#为了方便，这里直接将filebeat收集到的日志倒入kafka，而不经过logstash，实际应用中按需配置。
```

```shell
systemctl stop filebeat
systemctl start filebeat
```


## 编写flink任务
### 脚本语言
`flink` 可以通过 `java` 编写脚本程序，也可以通过 `python` 的 `pyflink` 进行脚本编写。

我这里为了方便使用，选择了 `python` 。
### 使用模式
`flink` 有 `Table API & SQL` 和 `DataStream API` 两种接口。
个人理解，`Table API & SQL` 更类似常见的 `sql` 操作。而 `DataStream API` 有点类似 `Pandas` 的使用方法。
下文实例中选择了  `Table API & SQL` 方法。

### DEMO需求梳理
1. 从 `kafka` 中读取日志数据
2. 将日志数据进行整理，提取出`类名`，`日志级别`，`日志时间`，`日志内容`等字段。
3. 将整理好的日志重新写入 `kafka` 中。

### 开发环境准备
```shell
python -m pip install apache-flink==1.16.0 # 安装python pyflink包
wget https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-kafka/1.16.1/flink-sql-connector-kafka-1.16.1.jar #kafka链接包
```

### 脚本编写
```python
from pyflink.table import (EnvironmentSettings, TableEnvironment)

env_settings = EnvironmentSettings.in_streaming_mode()
t_env = TableEnvironment.create(env_settings)
t_env.get_config().set("pipeline.jars","file:///root/src/python/kafka/lib/flink-sql-connector-kafka-1.16.1.jar") #这里需要引入flink-sql-connector-kafka，flink默认情况下不支持链接kafka，只有加载这个jar包才能链接kafka

# 创建source 表，用于记录原始数据。这里因为只关心message字段，所以 source表只用message一个字段。字段类型是STRING，这里需要注意，flink的字段类型与常见sql的字段类型有区别。具体可以通过 https://nightlies.apache.org/flink/flink-docs-release-1.16/zh/docs/dev/python/table/python_types/ 查看 
# 数据来源为with后的配置，这里定义了来源类型等信息。具体配置方法可以通过 https://nightlies.apache.org/flink/flink-docs-release-1.16/zh/docs/dev/python/table/python_table_api_connectors/ 查看
# 这里配置的是，读取10.13.13.111:9092的log_104topic中的信息。
t_env.execute_sql("""create table source ( message STRING ) with ( 'connector' = 'kafka','topic' = 'log_104','properties.bootstrap.servers' = '10.13.13.111:9092','properties.group.id' = 'testGroup','scan.startup.mode' = 'earliest-offset','format' = 'json' )""")
# log104 数据示例：
# {"@timestamp":"2023-02-06T07:33:06.707Z","@metadata":{"beat":"filebeat","type":"_doc","version":"8.5.0"},"agent":{"id":"1f8bb914-d950-4966-9ec7-d409fe1a92a1","name":"104.fu","type":"filebeat","version":"8.5.0","ephemeral_id":"64e69b04-fe68-4953-bc3f-7687a57046d7"},"log":{"offset":541482,"file":{"path":"/tmp/1.log"}},"message":"2023-02-06 15:33:06,350 - func4 - ERROR - Life is a horse, and either you ride it or it rides you.","input":{"type":"filestream"},"ecs":{"version":"8.0.0"},"host":{"architecture":"x86_64","os":{"codename":"Core","type":"linux","platform":"centos","version":"7 (Core)","family":"redhat","name":"CentOS Linux","kernel":"3.10.0-1160.80.1.el7.x86_64"},"name":"104.fu","id":"7219104f3d49439597809bcd4b8323f0","containerized":false,"ip":["10.13.13.104","fe80::5054:ff:fea7:4ca9"],"mac":["52-54-00-A7-4C-A9"],"hostname":"104.fu"}}

# source 数据示例
# "message":"2023-02-06 15:33:06,350 - func4 - ERROR - Life is a horse, and either you ride it or it rides you."


# 创建sink表，用于存储整理后的日志信息。其中包括四个字段。分别是时间，日志级别，方法名称，日志内容。
# 数据源配置方法同上。
# 这里配置数据源为log_out topic
t_env.execute_sql("""create table sink ( timestr STRING,loglevel STRING,funcname STRING,message STRING ) with ( 'connector' = 'kafka','topic' = 'log_out','properties.bootstrap.servers' = '10.13.13.111:9092','properties.group.id' = 'testGroup','scan.startup.mode' = 'earliest-offset','format' = 'json' )""")

# 将source表中的日志整理后存入sink表中
# 注意这里使用的函数不是sql自带的函数，而是flink中自带的函数。具体可以通过 https://nightlies.apache.org/flink/flink-docs-release-1.16/zh/docs/dev/table/functions/systemfunctions/ 查看
t_env.execute_sql("INSERT into sink SELECT SPLIT_INDEX( message, ' - ', 0 ),SPLIT_INDEX( message, ' - ', 1 ),SPLIT_INDEX( message, ' - ', 2 ),SPLIT_INDEX( message, ' - ', 3 ) FROM source  ")

# 结果数据示例：{"timestr":"2023-02-06 14:59:08,371","loglevel":"func4","funcname":"ERROR","message":"The best hearts are always the bravest."}


# 通过上述代码，可以将filebeat收集到的数据进行分割。
# 在此基础上，可以进行分类和清理。
 ```


### 将脚本传入服务器
```shell
/soft/flink-1.16.1/bin/flink run -py /root/src/python/kafka/test.py 
# 通过上述命令即可将脚本传入flink中执行。
#在开发时，也可以直接使用如下命令执行脚本
python test.py 
# 通过这种方式执行后，脚本是通过py环境中的flink进行执行的。
```

### 附录
## 通过filebeat 对日志进行过滤
```yml
# 通过正则表达式，将日志进行过滤，对过滤后的日志打上不同标签。
# 然后通过不同标签传入不同的topic中完成日志分类。
filebeat.inputs:
- type: filestream
  id: info-log 
  enabled: true
  paths:
    - /tmp/1.log
  include_lines: ['func[[:digit:]] - INFO']
  fields:
    topic: info-log
- type: filestream
  id: warning-log
  enabled: true
  paths:
    - /tmp/1.log
  include_lines: ['func[[:digit:]] - WARNING']
  fields:
    topic: warning-log
- type: filestream
  id: err-log
  enabled: true
  paths:
    - /tmp/1.log
  exclude_lines: ['func[[:digit:]] - INFO','func[[:digit:]] - WARNING']
  fields:
    topic: err-log

output.kafka:
  hosts: ["10.13.13.111:9092"]
  topic: '%{[fields.topic]}' 
```