---
title: my.cnf
date: 2019-11-14
updated: 2019-11-15
tags:
  - mysql
categories:
  - file
abbrlink: a4b910a9
---
```
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
user=mysql
# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
[mysqld_safe]
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
```
