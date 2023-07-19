---
title: haproxy日志格式
date: 2020-8-25
updated: 2020-8-26
categories:
  - note
abbrlink: 4e02053d
---
## **haproxy日志格式**



May  4 11:40:26 localhost haproxy[16534]: 172.18.101.254:56412 [04/May/2017:11:40:26.701] stats-front stats-back/<STATS> 0/0/7 34204 LR 61/2/0/0/0 0/0



![enter description here][1]


  [1]: ./images/haproxy%E6%97%A5%E5%BF%97%E6%A0%BC%E5%BC%8F%E8%AF%A6%E8%A7%A3.png "haproxy日志格式详解"


| 显示    |  详解   |
| --- | --- |
|    May  4 11:40:26 |   时间  |
|    localhost |   \  |
|     haproxy[16534] |  进程名称与PID   |
|   172.18.101.254:56412  |   客户端的地址与端口  |
|  [04/May/2017:11:40:26.701]   |   连接时间  |
|  stats-front   | front名称    |
|   stats-back  |  back名称   |
|   <STATS>  |  服务名称   |
|   0  |  是指在请求队列中等待的总时间，如果是-1的话 代表客服端主动断开请求   |
|   0  |  是指用来连接后端server tcp建联总时间，如果是-1的话 代表客服端在tcp建联的时候断开请求   |
| 7 | 是指haproxy完成整个请求的总时间 //包括接受请求 向后端发起 接收后端的内容 和重试的所有时间 // |
| 34204 | 日志记录时 所以经过haproxy 传输的字节数 |
| LR | / |
| 61 | 会话记录过程中进程并发连接数 |
| 2 | 会话记录过程中frontend中的并发连接数 |
| 0 | 会话记录过程中backend中已经建立握手的并发连接数 |
| 0 | 会话记录过程中活跃的并发连接数 |
| 0 | 会话记录过程中重试后端server的次数 |
| 0|  处理改请求时 server端的队列正在处理的连接数|
| 0| 处理改请求是 backend队列正在处理的连接数|