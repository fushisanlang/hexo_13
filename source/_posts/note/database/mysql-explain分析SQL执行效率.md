---
title: mysql优化–explain分析sql语句执行效率
date: 2026-06-15
tags:
  - mysql
  - explain
  - sql优化
  - 索引
categories:
  - note
---

Explain 命令用来分析 SQL 语句的执行效果，帮助选择更好的索引和优化查询语句。

<!--more-->

## 基本语法

```sql
EXPLAIN select * from news;
```

## 关键字段说明

### type（连接类型）

从好到差依次：

| type值 | 含义 |
|--------|------|
| system | 表仅有一行 |
| const | 通过索引一次命中 |
| eq_ref | 唯一性索引扫描 |
| ref | 非唯一性索引扫描 |
| range | 索引范围扫描 |
| index | 全索引扫描 |
| ALL | 全表扫描（最差） |

### key

显示 MySQL 实际决定使用的键（索引）。如果为 NULL，表示没有使用索引。

### rows

显示 MySQL 认为执行查询时必须检查的行数。越少越好。

### Extra

包含 MySQL 解决查询的详细信息，常见值：

| 值 | 含义 |
|----|------|
| Using filesort | 文件排序，需优化 |
| Using temporary | 使用临时表，需优化 |
| Using index | 覆盖索引，性能好 |
| Using where | 使用 WHERE 过滤 |

### possible_keys

MySQL 能使用哪个索引在该表中找到行。

### key_len

MySQL 决定使用的键长度，越短越好。

### ref

显示使用哪个列或常数与 key 一起从表中选择行。

## 优化方向

- 尽量让 type 达到 range 及以上（避免 ALL 全表扫描）
- key 列不应为 NULL
- rows 尽量小
- Extra 避免 Using filesort 和 Using temporary
