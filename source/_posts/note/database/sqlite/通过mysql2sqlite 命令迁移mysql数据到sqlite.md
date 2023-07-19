---
title: 通过mysql2sqlite 命令迁移mysql数据到sqlite
date: 2023-6-20
updated: 2023-6-20
tags:
  - mysql
  - sqlite
  - trans
  - mysql2sqlite
categories:
  - note
abbrlink: ed2658fc
---

### 通过mysql2sqlite 命令迁移mysql数据到sqlite
* 背景
因为某些原因，需要将存储在 `mysql` 中的数据转存到 `sqlite3` 中。
但是直接使用 `mysqldump` 得到的 `sql` ，很多关键字和字段类型 `sqlite3` 不支持。
所以找了一个工具，可以直接使用。

* 安装
```shell
pip3 install mysql-to-sqlite3
```


* 迁移
```shell
mysql2sqlite  -f windsmeller.db -d windsmeller -u root -p  -h 127.0.0.1
# -f sqlite 数据文件
# -d mysql 中的数据库
# -u mysql 用户
# -p mysql 密码
# -h mysql 地址
```




