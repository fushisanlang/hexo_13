---
title: MySQL权限整理及授权命令
date: 2026-06-15
tags:
  - mysql
  - 权限
  - 数据库
categories:
  - note
---

MySQL 权限级别：服务器 → 数据库 → 表 → 列。另外还有存储过程、视图和索引。

<!--more-->

## MySQL 权限列表

| 权限 | 作用范围 | 作用 |
|------|---------|------|
| all | 服务器 | 所有权限 |
| select | 表、列 | 选择行 |
| insert | 表、列 | 插入行 |
| update | 表、列 | 更新行 |
| delete | 表 | 删除行 |
| create | 数据库、表、索引 | 创建 |
| drop | 数据库、表、视图 | 删除 |
| reload | 服务器 | 允许使用 flush 语句 |
| shutdown | 服务器 | 关闭服务 |
| process | 服务器 | 查看线程信息 |
| file | 服务器 | 文件操作 |
| grant option | 数据库、表、存储过程 | 授权 |
| references | 数据库、表 | 外键约束的父表 |
| index | 表 | 创建/删除索引 |
| alter | 表 | 修改表结构 |
| show databases | 服务器 | 查看数据库名称 |
| super | 服务器 | 超级权限 |
| create temporary tables | 表 | 创建临时表 |
| lock tables | 数据库 | 锁表 |
| execute | 存储过程 | 执行 |
| replication client | 服务器 | 允许查看主从/二进制日志状态 |
| replication slave | 服务器 | 主从复制 |
| create view | 视图 | 创建视图 |
| show view | 视图 | 查看视图 |
| create routine | 存储过程 | 创建存储过程 |
| alter routine | 存储过程 | 修改/删除存储过程 |
| create user | 服务器 | 创建用户 |
| event | 数据库 | 创建/更改/删除/查看事件 |
| trigger | 表 | 触发器 |
| create tablespace | 服务器 | 创建/更改/删除表空间/日志文件 |
| usage | 服务器 | 无权限（只允许登录） |

## 常用授权命令

### 基本授权

```sql
-- 授权用户所有权限
GRANT ALL PRIVILEGES ON *.* TO 'username'@'localhost' IDENTIFIED BY 'password';
FLUSH PRIVILEGES;

-- 授权特定数据库
GRANT ALL PRIVILEGES ON mydb.* TO 'username'@'%' IDENTIFIED BY 'password';

-- 授权特定表
GRANT SELECT, INSERT, UPDATE, DELETE ON mydb.mytable TO 'username'@'%';

-- 授权远程登录
GRANT ALL PRIVILEGES ON *.* TO 'username'@'%' IDENTIFIED BY 'password';
```

### 查看权限

```sql
SHOW GRANTS FOR 'username'@'localhost';
```

### 撤销权限

```sql
REVOKE ALL PRIVILEGES ON *.* FROM 'username'@'%';
REVOKE GRANT OPTION ON mydb.* FROM 'username'@'%';
FLUSH PRIVILEGES;
```

### 删除用户

```sql
DROP USER 'username'@'localhost';
```

## 最小权限原则

- 应用账户：只给 SELECT/INSERT/UPDATE/DELETE
- 备份账户：SELECT + LOCK TABLES + REPLICATION CLIENT
- 管理账户：SUPER + SHUTDOWN + PROCESS（按需分配）
