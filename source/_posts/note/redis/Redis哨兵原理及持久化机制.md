---
title: Redis哨兵原理及持久化机制
date: 2026-06-15
tags:
  - redis
  - 哨兵
  - sentinel
  - 持久化
  - RDB
  - AOF
categories:
  - note
---

Redis 哨兵（Sentinel）原理及故障转移过程，以及 RDB/AOF 持久化机制对比。

<!--more-->

## Sentinel 工作流程

1. 每个 Sentinel 以每秒一次的频率向 Master、Slave 及其他 Sentinel 发送 PING 命令
2. 如果实例距离最后一次有效回复超过 `down-after-milliseconds`，被标记为**主观下线**
3. 监视该 Master 的所有 Sentinel 以每秒一次确认 Master 进入了主观下线状态
4. 足够数量的 Sentinel（≥ 配置值）在指定时间内确认后，Master 被标记为**客观下线**
5. Master 被标记客观下线后，对 Slave 的 INFO 命令频率从 10 秒一次改为每秒一次
6. 若不够 Sentinel 同意，Master 客观下线状态解除

## 故障转移过程

7. Sentinel 节点间投票选举一个 Sentinel 执行故障处理
8. 从 Slave 中选取一个作为新的 Master，其他从节点自动挂载新主节点

## 新 Master 选举标准

1. **断开时长**：与 Master 断开超过 `(down-after-milliseconds * 10) + master宕机时长` 的不适合选举
2. **优先级**：slave priority 越低优先级越高（`replica-priority` 配置）
3. **复制 offset**：复制数据越多的 offset 越靠后，优先级越高
4. **run id**：以上相同则选 run id 较小的

## 配置信息传播

- 故障转移完成后，执行的 Sentinel 在本地更新最新 master 配置
- 通过 pub/sub 机制同步给其他 Sentinel
- 每次切换生成唯一的 `configuration epoch`（version 号）
- 其他 Sentinel 根据 version 号大小更新自己的配置

## 持久化机制

### RDB

- 定时生成数据快照文件，适合做冷备
- fork 子进程执行，对主进程影响小
- 恢复速度比 AOF 快（直接加载到内存）
- **缺点**：故障时可能丢失较多数据（依赖快照间隔），fork 可能阻塞客户端

### AOF

- 记录每次写命令到文件尾部，追加写入效率高
- 每秒执行一次 fsync，最多丢失 1 秒数据
- **缺点**：文件较大时恢复耗时，对写性能有一定影响
- 支持 bgrewriteaof 压缩日志文件

### 生产建议

- **高数据保障性**：同时开启 RDB + AOF
- **可接受少量数据丢失**：仅用 RDB
- RDB 做快速恢复，AOF 做数据保障
