---
title: sentinel.conf
date: 2016-12-3
updated: 2016-12-4
tags:
  - redis
  - sentinel
categories:
  - file
abbrlink: 9de43bc8
---

```
port 26379 
daemonize yes
protected-mode no
logfile "/home/redis/logs/sentinel.log" 
sentinel announce-ip 
192.168.0.201                       
sentinel monitor mymaster 192.168.0.201 6379 2 
sentinel down-after-milliseconds mymaster 15000 
sentinel failover-timeout mymaster 900000
sentinel parallel-syncs mymaster 1
```
