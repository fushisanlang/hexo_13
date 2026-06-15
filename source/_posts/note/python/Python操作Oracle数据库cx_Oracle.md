---
title: Python操作Oracle数据库：cx_Oracle
date: 2026-06-15
tags:
  - python
  - oracle
  - cx_Oracle
  - 数据库
categories:
  - note
---

Python 操作 Oracle 数据库多用 cx_Oracle 这个第三方扩展，总体而言，cx_Oracle 的使用方式与 Python 操作 MySQL 数据库的 pymysql 库还是很相似的。

<!--more-->

## 安装与导入

```bash
pip install -i https://pypi.douban.com/simple cx_oracle
```

使用前导入：

```python
import cx_Oracle
```

千万注意，包名称 cx_Oracle 中，字母 "O" 是大写的，写成小写将会导入失败。

安装好 cx_Oracle 第一次使用时，出现 `DatabaseError: DPI-1047`，可以按照官方文档解决：https://oracle.github.io/odpi/doc/installation.html#linux

## 创建连接

cx_Oracle 提供了两种方式连接 Oracle 数据库：创建独立的单一连接以及创建连接池。

### 单一连接

通过 `cx_Oracle.connect()` 方法实现：

```python
# 基本连接
connection = cx_Oracle.connect("username", "password", "192.168.1.2/helowin", encoding="UTF-8")

# 指定端口
connection = cx_Oracle.connect("username", "password", "192.168.1.2:1521/helowin", encoding="UTF-8")

# 管理员身份登录（sysdba）
connection = cx_Oracle.connect("sys", "psdpassword", "192.168.1.2:1521/helowin",
                                mode=cx_Oracle.SYSDBA, encoding="UTF-8")
```

关闭连接：

```python
connection.close()
```

### 连接池

使用 `SessionPool()` 创建连接池，需要额外指定最少连接数（min）和最大连接数（max）：

```python
# 创建连接池
pool = cx_Oracle.SessionPool("username", "password",
                               "192.168.1.2:1521/helowin",
                               min=2, max=5, increment=1, encoding="UTF-8")

# 从连接池中获取一个连接
connection = pool.acquire()

# 使用连接进行查询
cursor = connection.cursor()
for result in cursor.execute("select * from scott.students"):
    print(result)

# 将连接放回连接池
pool.release(connection)

# 关闭连接池
pool.close()
```

多线程下使用时，应该传递 `threaded=True`：

```python
pool = cx_Oracle.SessionPool("username", "password",
                               "192.168.1.2:1521/helowin",
                               min=2, max=5, increment=1, threaded=True, encoding="UTF-8")
```

## 游标

通过连接获取游标：

```python
cur = connection.cursor()
```

游标使用完毕后记得关闭：

```python
cur.close()
```

## 执行SQL

`Cursor.execute()` 方法一次只能执行一条 SQL 语句，`Cursor.executemany()` 一次可执行多条 SQL，当有类似的大量 SQL 语句需要执行时，使用 `executemany()` 可以极大提升性能。

```python
cur.execute("select * from SCOTT.STUDENTS")

# 绑定变量
cur.execute("select * from SCOTT.STUDENTS where ID = :id", {"id": 1})

# executemany
data = [(1, '张三', 20), (2, '李四', 30)]
cur.executemany("insert into SCOTT.STUDENTS values (:1, :2, :3)", data)
```

## 注意事项

- cx_Oracle 执行的语句都含有分号 `;` 或斜杠 `/`
- 连接Oracle需要安装 Oracle Instant Client
