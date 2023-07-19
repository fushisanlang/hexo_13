---
title: 搭建redis-5集群
date: 2019-8-11
updated: 2019-8-12
tags:
  - redis cluster
  - redis
categories:
  - note
abbrlink: a7ecd64e
---

## 1.  环境说明

软件|版本
-|-
os|centos 7.7
redis|5.0.12

ip|用途
-|-
192.168.1.2|redis
192.168.1.3|redis
192.168.1.4|redis

## 2. 安装
*每台主机上操作一次*

```shell
mkdir /soft
cd /soft
wget https://download.redis.io/releases/redis-5.0.12.tar.gz
tar xf redis-5.0.12.tar.gz
cd redis-5.0.12
yum install gcc -y
make && make install
```

## 3. 配置
*每台主机上操作一次*
```shell
cd /soft/redis-5.0.12/utils
sh install_server.sh #进行默认配置
#默认设置里边不会设置redis-cli的路径，如果机器上有其他版本的redis，可能会造成冲突。不过问题不大。如果害怕冲突可以按照如下步骤操作。


mkdir -p /usr/local/redis5/bin
mkdir -p /usr/local/redis5/conf
cd /soft/redis-5.0.12
cp redis.conf /usr/local/redis-5/conf/
cd src/
cp mkreleasehdr.sh redis-benchmark redis-check-aof redis-cli redis-server /usr/local/redis-5/bin/ 

vim /usr/local/redis5/conf/redis.conf
#注意修改如下内容。其他配置按需修改
```

```conf
bind 0.0.0.0
protected-mode no
port 16379
daemonize yes
pidfile /usr/local/redis-5/redis_16379.pid 
requirepass redis_16379 
appendonly yes
cluster-enabled yes
cluster-config-file nodes-16379.conf
cluster-node-timeout 15000
```

```shell
useradd -s /sbin/nologin redis 
cat >> /usr/lib/systemd/system/redis5.service << EOF

[Unit]
Description=redis
After=network.target

[Service]
Type=forking
PIDFile=/usr/local/redis-5/redis_16379.pid
ExecStart=/usr/local/redis-5/bin/redis5-server /usr/local/redis-5/conf/redis_16379.conf
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true
User=redis
Group=redis

[Install]
WantedBy=multi-user.target
EOF


systemctl daemon-reload
systemctl status redis5
systemctl start redis5

/usr/local/redis-5/bin/redis-cli -a redis_16379 -p 16379 -h 192.168.1.2 #测试连接

```

## 4. 配置集群

```shell
#3个节点启动完成后，在其中一个节点上执行一下命令即可创建集群
/usr/local/redis-5/bin/redis5-cli -a redis_16379 --cluster create 192.168.1.2:16379 192.168.1.3:16379 192.168.1.4:16379 --cluster-replicas 0


#集群连接方式
/usr/local/redis-5/bin/redis-cli -a redis_16379 -p 16379 -h 192.168.1.2 -c
```
