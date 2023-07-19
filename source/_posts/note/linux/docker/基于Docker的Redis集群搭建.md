---
title: 基于Docker的Redis集群搭建
date: 2018-2-15
updated: 2018-2-16
tags:
  - docker
  - redis cluster
  - redis
categories:
  - note
abbrlink: 4052dcda
---

# 镜像版本

redis：5.0.12

# 拉取镜像

```shell
docker pull redis:5.0.12
```

# 准备挂载路径

```shell
mkdir -p /data/redis_63{79..81}/{conf,data}
vim /data/redis_6379/conf/redis.conf
	bind 0.0.0.0
	port 6379
	daemonize no
	pidfile "/var/run/redis_6379.pid"
	logfile ""
	dir "./"
	masterauth redis_1.35
	requirepass redis_1.35
	appendonly yes
	cluster-enabled yes
	cluster-config-file nodes_6379.conf
	cluster-node-timeout 15000
sed 's/6379/6380/g' /data/redis_6379/conf/redis.conf > /data/redis_6380/conf/redis.conf
sed 's/6379/6381/g' /data/redis_6379/conf/redis.conf > /data/redis_6381/conf/redis.conf
```

# 启动容器

```shell
docker run -p 6379:6379 --name redis-6379 -v /data/redis_6379/conf:/etc/redis -v /data/redis_6379/data:/data --restart=always --privileged=true -d redis:5.0.12 redis-server /etc/redis/redis.conf
docker run -p 6380:6380 --name redis-6380 -v /data/redis_6380/conf:/etc/redis -v /data/redis_6380/data:/data --restart=always --privileged=true -d redis:5.0.12 redis-server /etc/redis/redis.conf
docker run -p 6381:6381 --name redis-6381 -v /data/redis_6381/conf:/etc/redis -v /data/redis_6381/data:/data --restart=always --privileged=true -d redis:5.0.12 redis-server /etc/redis/redis.conf
```

# 查看节点ip信息

```shell
docker inspect redis-6379 | grep '"IPAddress"' #记录ip，下同
docker inspect redis-6380 | grep '"IPAddress"'
docker inspect redis-6381 | grep '"IPAddress"'
```

# 组建集群

```shell
docker exec -ti redis-6379 redis-cli -a 123456 --cluster create 10.0.42.10:6379 10.0.42.9:6380 10.0.42.11:6381 --cluster-replicas 0
```

# 连接集群测试

```shell
docker exec -ti redis-6379 redis-cli -a redis_1.35 -c
```