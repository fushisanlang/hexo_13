---
title: Redis数据备份和重启恢复
date: 2026-06-15
tags:
  - redis
  - 持久化
  - RDB
  - AOF
  - 备份
categories:
  - note
---

Redis 持久化的两种方式：RDB 和 AOF。用于重启后的数据恢复。

<!--more-->

## RDB 快照

RDB（Snapshot）是默认的持久化方式，按照一定的策略周期性的将数据保存到磁盘，对应数据文件为 `dump.rdb`。

### 默认快照设置

```bash
save 900 1    # 当有一条 Keys 数据被改变时，900秒刷新到 Disk 一次
save 300 10   # 当有10条 Keys 数据被改变时，300秒刷新到 Disk 一次
save 60 10000 # 当有10000条 Keys 数据被改变时，60秒刷新到 Disk 一次
```

### RDB 的优点

- Redis 的 RDB 文件不会坏掉，因为写操作是在一个新进程中进行的
- 生成新的 RDB 文件时，父进程 fork 出子进程，先写到临时文件，然后 rename 替换
- 主从同步的基础：第一次同步时 Master dump 出 rdb 文件传给 Slave

### RDB 的不足

一旦数据库出现故障，RDB 文件中保存的数据不是全新的。上次 RDB 文件生成到 Redis 停机期间的数据会丢失。

## AOF 日志

AOF（Append-Only File）持久化性更好，将每个收到的写命令通过 Write 函数追加到文件中，类似于 MySQL 的 binlog。

```bash
appendonly yes                       # 启用 AOF 持久化方式
appendfilename appendonly.aof        # AOF 文件的名称

# appendfsync always  # 每次收到写命令就立即强制写入磁盘，最慢
appendfsync everysec  # 每秒钟强制写入磁盘一次，推荐
# appendfsync no      # 完全依赖 OS 的写入，约30秒一次
```

### AOF 重写

AOF 文件会随时间变得越来越大，bgrewriteaof 命令可以压缩：

```bash
no-appendfsync-on-rewrite yes   # 日志重写时，不进行命令追加操作
auto-aof-rewrite-percentage 100 # 当前 AOF 文件是上次重写文件的二倍时，启动新的日志重写
auto-aof-rewrite-min-size 64mb  # 启动新的日志重写过程的最小值
```

## 官方建议

- **高数据保障性**：同时使用 RDB + AOF
- **可接受几分钟数据丢失**：仅使用 RDB
- 通常建议同时使用两种方式，取长补短

## 数据恢复速度

RDB 启动更快：
1. 每条数据只有一条记录，不像 AOF 可能有多次操作
2. RDB 文件格式与 Redis 内存编码一致，不需要额外编码转换

## 推荐架构

Master 不做持久化保证读写性能，Slave 同时开启 Snapshot 和 AOF 保证数据安全：

**Master 配置：**
```bash
# save 900 1
# save 300 10
# save 60 10000
appendonly no
```

**Slave 配置：**
```bash
save 900 1
save 300 10
save 60 10000

appendonly yes
appendfsync everysec
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
```
