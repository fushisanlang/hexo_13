---
title: hadoop
date: 2017-8-6
updated: 2017-8-7
tags:
  - hadoop
categories:
  - note
abbrlink: b4989874
---


## 试验环境准备

server1.example.com ip:172.25.34.1    
server2.example.com ip:172.25.34.2    
server3.example.com ip:172.25.34.3    
server4.example.com ip:172.25.34.4    

<!--more-->

## hadoop安装

新建hadoop用户是为了在不同的节点都有相同的用户。

需要注意的是，不同节点的时间需要保持一致（大多数的集群都有这种需求），并且互相之间可以通过ssh无密码访问(具体做法会在后文提到),并且应该有相互之间的解析。

    # useradd -u 900 hadoop
    #   passwd hadoop

软件解压即可用，无需特意安装。但是为了方便实用，推荐将软件解压到hadoop用户的家目录中，并且添加软连接。即

    # su - hadoop
    $ ln -s  jdk1.7.0_79 java
    $ ln -s hadoop-1.2.1/ hadoop
    $ cd ~/hadoop/conf
    $ vim hadoop-env.sh
        export JAVA_HOME=/home/hadoop/java   //第九行

##  单节点使用使用



    $ cd ~/hadoop/
    $ mkdir input 
    $ cp conf/* input/
    $ bin/hadoop jar hadoop-examples-1.2.1.jar grep input output 'dfs[a-z.]+'  
    //这是一条测试用的命令，用来过滤所有以dfs开始的文件，将结果保存到output目录中
    $ cat output/*

## 伪分布式使用

    $ cd ~/hadoop/ 
    $ rm -fr output input 
    $ cd conf 
    $vim core-site.xml //定义主节点
        <property>  //放在<configuration> 与</configuration> 之间，下同
        <name>fs.default.name</name>   
        <value>hdfs://172.25.34.1:9000</value>
        </property>
    $ vim hdfs-site.xml 
    //定义数据备份数量，因为只有一个节点，所以只需要备份一份
        <property>
        <name>dfs.replication</name>
        <value>1</value>
        </property>
    $ vim mapred-site.xml //job分发节点
        <property>
        <name>mapred.job.tracker</name>
        <value>172.25.34.1:9001</value>
        </property>
    $ vim master
        172.25.34.1
    $ vim slaves 
    //定义运算服务器，因为是伪分布式，所以仍然是本机`
        172.25.34.1
    $ ssh-keygen
    $ ssh-copy-id 172.25.34.1
    $ cd ~/hadoop/bin
    $ ./hadoop namenode -format 
    //配置分布式文件系统，如果不进行这一步，就无法使用伪分布式hadoop
    $ ./start-all.sh //启动 伪分布式hadoop 
    $ ~/java/bin/jps //通过java自带的命令查看java开启的进程
    $ bin/hadoop fs 
    //通过此命令对伪分布式hadoop进行使用，具体使用方法与单机版相似 
    $ bin/hadoop fs -put conf input #把conf目录上传并命名为input 
    $ bin/hadoop jar hadoop-examples-1.2.1.jar grep input output 'dfs[a-z.]+' 
    //测试命令
***

可以通过172.25.34.1：50030  172.25.34.1：50070 监控

## 分布式使用

**环境准备：**   
因为想要做一个hadoop集群，所以应该保证不同节点之间的hadoop用户相同，时间相同，配置文件相同，并且因为hadoop的master通过ssh与slaves连接，所以还要保证master与slaves的ssh-key。所以为了方便操作，推荐使用nfs文件系统共享。

具体做法如下：

**server1**

    $ cd ~/hadoop/ 
    $ bin/stop-all.sh 
    $ vim slaves 
        172.25.34.2
        172.25.34.3
    $ vim hdfs-site.xml //适当增加保存份数 
    $ rm -fr /tmp/* 

    # vim /etc/exports 
        /home/hadoop	*(rw,anonuid=900,anongid=900)
    # /etc/init.d/rpcbind start 
    # /etc/init.d/nfs start 
    # exportfs -rv

**server2.3**

    # useradd -u 900 hadoop 
    # passwd hadoop 
    # /etc/init.d/rpcbind start 
    # /etc/init.d/nfs start 
    # showmount -e 172.25.34.2
    # mount 172.25.34.2:/home/hadoop/ /home/hadoop/ 

**server1**

    $ ./hadoop namenode -format
    $ ./start-all.sh
    $ bin/hadoop fs -put conf input
    $ bin/hadoop jar hadoop-examples-1.2.1.jar grep input output 'dfs[a-z.]+'
    $ bin/hadoop dfsadmin -report //查看节点状态

## 热添加节点

将要添加的节点进行上步中的配置。

然后通过hadoop自带的命令进行添加。

    $ cd ~/dadoop/
    $ echo "172.25.34.4" >> conf/slaves
    $ bin/hadoop-daemon.sh start datanode
    $ bin/hadoop-daemon.sh start tasktracker
    $ bin/hadoop dfsadmin -report

## 迁移节点

    $ vim mapred-site.xml
        <property>    // 加在之前添加之后，</configuration>之前
        <name>dfs.hosts.exclude</name>
        <value>/home/hadoop/hadoop/conf/host-exclude</value>
        </property>
    $ echo "172.25.34.3" > /home/hadoop/hadoop/conf/host-exclude
    $ bin/hadoop dfsadmin -refreshNodes 
    //刷新节点信息

通过这种方式就可以将节点的数据迁移到其他节点，然后移除。需要注意的是，进行数据迁移时，节点不能进行运算操作。

如果节点正在运算，可以通过

    $ bin/hadoop-daemon.sh stop tasktracker

命令停止运算。



# hadoop 2

**server1**

此处是hadoop2版本，相对于1稍有区别，但是对虚拟机环境要求不变。所以只需要将之前的1的文件删除，改为2即可继续实验

    $ ln -s hadoop-2.6.4 hadoop
    $ cd ~/hadoop/etc/hadoop/
    $ vim hadoop-env.sh
        export JAVA_HOME=/home/hadoop/java
        export HADOOP_PREFIX=/home/hadoop/hadoop
    $ vim core-site.xml 
        <property>
        <name>fs.defaultFS</name>
        <value>hdfs://172.25.34.1:9000</value>
        </property>
    $ vim hdfs-site.xml
        <property>
        <name>fs.replication</name>
        <value>1</value>
        </property>
    $ cd /home/hadoop/hadoop/bin
    $ vim slaves
        172.25.34.2
        172.25.34.3
    $ cd  /home/hadoop/hadoop
    $ sbin/start-dfs.sh
    $ cp hadoop-native-64-2.6.0.tar /home/hadoop/hadoop/lib 
    $ cd /home/hadoop/hadoop/lib 
    $ tar xf hadoop-native-64-2.6.0.tar 
    $ mkdir native/ 
    $ mv * native/ 
    $ sbin/stop-dfs.sh  
    $ bin/hdfs dfs -mkdir /user 
    $ bin/hdfs dfs -mkdir /user/hadoop
    $ cd /home/hadoop/hadoop/etc/hadoop
    $ cp mapred-site.xml.template mapred-site.xml
    $ vim mapred-site.xml
        <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
        </property>
    $ vim yarn-site.xml 
        <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
        </property>
    $ cd /home/hadoop/hadoop
    $ sbin/start-yarn.sh 
***
可以通过172.25.34.1：8088实时监控。
