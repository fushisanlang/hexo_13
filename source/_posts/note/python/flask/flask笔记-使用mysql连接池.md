---
title: flask笔记-使用mysql连接池
date: 2016-2-3
updated: 2016-2-4
tags:
  - python
  - flask
  - mysql-connecter-pooling
categories:
  - note
abbrlink: d0a690e1
---

# flask笔记-使用mysql连接池

在项目中，因为需要频繁进行sql操作，如果不使用连接池，在sql操作时每次都要重新建立连接，影响性能。

这里使用的mysql-connecter模块自带的mysql-connecter-pooling连接池。

### 官方说明
[官网地址](https://dev.mysql.com/doc/connector-python/en/connector-python-connection-pooling.html)

### 实际使用
使用时我是分了三个步骤

1.创建连接池
`create_db_pool.py`
```python
import mysql.connector.pooling

from readconf import readconf

host = readconf("Mysql-Database", "host")
user = readconf("Mysql-Database", "user")
password = readconf("Mysql-Database", "password")
database = readconf("Mysql-Database", "database")
port = readconf("Mysql-Database", "port")
pool_name = readconf("Mysql-Database", "pool_name")
pool_size = readconf("Mysql-Database", "pool_size")


db_pool = mysql.connector.pooling.MySQLConnectionPool(
    user=user, password=password, port=port, host=host, database=database, pool_name=pool_name, pool_size=int(pool_size))
```

2.封装sql操作函数
`operate_data.py`
```python3
import mysql.connector
from create_db_pool import db_pool

def select_operaction(select_key,tablename,select_require="1"):
    conn = db_pool.get_connection()
    conn.start_transaction()
    cursor = conn.cursor()
    sql_parm1 = "SELECT "
    sql_parm2 = select_key
    sql_parm3 = " FROM "
    sql_parm4 = tablename
    sql_parm5 = " where "
    sql_parm6 = select_require
    sql_parm7 = ";"
    sql = sql_parm1 + sql_parm2 + sql_parm3 + sql_parm4 + sql_parm5 + sql_parm6 + sql_parm7
    print(sql)
    cursor.execute(sql)
    result = cursor.fetchall()
    conn.close() #注意这里的关闭连接，如果不关闭会导致连接不释放。
    return result

def insert_operaction(tablename,keys,valuses):
    conn = db_pool.get_connection()
    conn.start_transaction()
    cursor = conn.cursor()
    sql_parm1 = "INSERT INTO "
    sql_parm2 = tablename
    sql_parm3 = " (" + keys +")"
    sql_parm4 = " VALUES (" + valuses + ");"
    sql = sql_parm1 + sql_parm2 + sql_parm3 + sql_parm4
    print(sql)
    cursor.execute(sql)
    conn.commit()
    conn.close() #注意这里的关闭连接，如果不关闭会导致连接不释放。
    return

    conn = db_pool.get_connection()
    conn.start_transaction()
    cursor = conn.cursor()
    sql_parm1 = "UPDATE "
    sql_parm2 = tablename
    sql_parm4 = key_str + ";"
    sql = sql_parm1 + sql_parm2 + sql_parm3 + sql_parm4
    print(sql)
    cursor.execute(sql)
    conn.commit()
    conn.close() #注意这里的关闭连接，如果不关闭会导致连接不释放。
    return
```

3.操作sql
```python
select_operaction("conf_value", "conf", "conf_key='world_id'")
```