---
title: docker部署oracle11g
date: 2018-9-11
updated: 2018-9-12
tags:
  - docker
  - oracle11g
categories:
  - note
abbrlink: 2ecdf7be
---


#### 1. 安装docker

[笔记](https://github.com/fushisanlang/own_note/blob/master/linux/linux%E7%AC%94%E8%AE%B0/centos7%E5%AE%89%E8%A3%85docker-ce.md)

#### 2. 部署oracle镜像

```shell
docker run -d -p 1521:1521 --name oracle_11g registry.aliyuncs.com/helowin/oracle_11g
```
<!--more-->
#### 3. 连接进入镜像进行配置

```shell
docker exec -it oracle_11g bash

#以下为docker中执行
su root
#密码helowin

vi /etc/profile
  export ORACLE_HOME=/home/oracle/app/oracle/product/11.2.0/dbhome_2
  export ORACLE_SID=helowin
  export PATH=$ORACLE_HOME/bin:$PATH
  
ln -s $ORACLE_HOME/bin/sqlplus /usr/bin

su - oracle
sqlplus /nolog
conn /as sysdba
SQL> alter user system identified by oracle; 
SQL> alter user sys identified by oracle;
SQL> ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;
```

使用服务名helowin及如下信息进行验证
ip 1521 helowin system oracle

#### 4. 分配用户及表空间

```shell
SQL> create tablespace financemediate datafile 'financemediate' size 8g;
SQL> create user financemediate default tablespace financemediate identified by "FINANCE_PASS_2020!@#";
SQL> grant connect,resource,dba to financemediate;
```

