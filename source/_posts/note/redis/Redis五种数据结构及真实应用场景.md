---
title: Redis五种数据结构及真实应用场景
date: 2026-06-15
tags:
  - redis
  - 数据结构
  - 应用场景
categories:
  - note
---

Redis 五种基本数据结构：String、Hash、List、Set、ZSet，以及真实应用场景解析。

<!--more-->

## String（字符串）

### 简介
Redis 中最基本、最常用的数据类型。二进制安全，可以存储 JSON、JPEG 等任意格式。

### 内部编码
- 整型数字 → `int`
- ≤39字节字符串 → `embstr`
- \>39字节 → `raw`

### 真实场景

**1. 缓存配置数据**
```python
# 地区表等少改数据，JSON存入String
r.set('areas', json.dumps(area_list))
```

**2. 缓存对象**
```python
r.set('user:1001', json.dumps(user_obj))
```

**3. 数据统计（自增自减）**
```bash
incr page_view:url_id    # 访问量计数
incr like:video_123      # 视频点赞
```

**4. 时间内限制请求（验证码5分钟有效）**
```python
key = f"sms:sent:{user_id}"
if r.exists(key):
    return "已发送过"
r.setex(key, 300, "1")   # 5分钟过期
send_sms()
```

**5. 订单号全局唯一**
```bash
SET order_no 2001
INCRBY order_no 1   # 返回 2002
```

**6. 分布式 Session**
```python
r.setex(f"session:{token}", 1800, json.dumps(user_data))
```

### 常用命令
```bash
set mykey "test"        # 设置值
setex mykey 10 "hello"  # 10秒过期
mset key3 "a" key4 "b"  # 批量设置
incr mykey              # +1
decrby mykey 5          # -5
get mykey
mget key3 key4
```

## Hash（哈希）

### 简介
类似 `Map<String, Map<String, String>>`，适合存储对象。可单独修改对象的某个字段，比 String 整体 JSON 更灵活。

### 内部编码
- 元素个数 <512，所有值 <64字节 → `ziplist`
- 否则 → `hashtable`

### 真实场景

**1. Redisson 分布式锁（可重入）**
锁内部用 Hash 存线程ID实现可重入。

**2. 购物车**
```
key = cart:{用户id}
field = 商品id
value = 数量
```
```bash
hset cart:1001 2001 1      # 添加商品
hincrby cart:1001 2001 1   # 数量+1
hlen cart:1001             # 商品总数
hdel cart:1001 2001        # 删除商品
hgetall cart:1001          # 获取全部商品
```

**3. 缓存对象**
```
hset user:1001 name "张三" age "25"
hset user:1001 email "zhangsan@example.com"
hget user:1001 name
hmset user:1002 name "李四" age "30"
```

## List（列表）

### 简介
链表，按插入顺序存储，可做栈/队列。元素可重复。

### 场景

**1. 最新消息/动态列表**
```bash
lpush user:1001:timeline "动态内容"
ltrim user:1001:timeline 0 99  # 只保留最新100条
lrange user:1001:timeline 0 -1
```

**2. 分页列表**
```python
# 先 lpush，后用 lrange 分页
start = (page-1) * size
end = page * size - 1
r.lrange('list:page', start, end)
```

## Set（集合）

### 简介
无序不重复集合，支持交集/并集/差集。

### 场景

**1. 标签（用户标签、文章标签）**
```bash
sadd article:1001:tags python redis mysql
smembers article:1001:tags
```

**2. 抽奖（不重复）**
```bash
sadd lottery:20240101 user1 user2 user3 user4
SRANDMEMBER lottery:20240101   # 随机抽1个（不删除）
SPOP lottery:20240101           # 随机抽1个（删除）
```

**3. 关注/粉丝**
```bash
sinter user:1001:follow user:1002:follow   # 共同关注
```

## ZSet（有序集合）

### 简介
每个元素带分值，按分值排序。不可重复。

### 场景

**1. 排行榜**
```bash
zadd leaderboard 100 "用户A"
zadd leaderboard 200 "用户B"
zrevrange leaderboard 0 9 withscores  # 前10名
zrank leaderboard "用户A"               # 获取排名
```

**2. 延时队列**
```python
# score 存时间戳
zadd delay:queue timestamp task_data
# 定时任务扫描
zrangebyscore delay:queue 0 current_time
zrem delay:queue task_data
```

**3. 热搜榜单**
```bash
zincrby hot:search 1 "端午节"
zrevrange hot:search 0 9
```
