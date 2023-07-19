---
title: Sysbench安装与使用
date: 2017-10-1
updated: 2017-10-2
tags:
  - Sysbench安装与使用
categories:
  - note
abbrlink: 72fdfee0
---
# Sysbench安装与使用

### 环境说明
centos 6.7 64位

Sysbench 1.0.16 

### 安装

```shell
#安装yum源
rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
yum install http://www.percona.com/downloads/percona-release/redhat/0.1-3/percona-release-0.1-3.noarch.rpm -y
#安装软件
yum -y install sysbench
```



### 参数选项

* 通用选项

```shell
General options:            # 通用选项
  --threads=N               要使用的线程数，默认 1 个 [1]
  --events=N                最大允许的事件个数，默认为[0]
  --time=N                  最大的总执行时间，以秒为单位默认为[10]
  --thread-stack-size=SIZE     每个线程的堆栈大小，默认为[64K]
  --rate=N                   指定数量多少事件(事务)平均每秒钟应该执行的所有线程。0(默认)意味着无限的速率,即事件尽快执行
  --report-interval=N          以秒为单位定期报告具有指定间隔的中间统计信息， 0 禁用中间报告，默认为0
  --debug[=on|off]             打印更多 debug 信息 [off]
  --validate[=on|off]            尽可能执行验证检查 [off]
  --help[=on|off]               显示帮助信息并退出 [off]
  --version[=on|off]             显示版本信息并退出 [off]
  --config-file=FILENAME        包含命令行选项的文件
  --tables=N                   表数量（数据库测试）
  --table-size=N                   表大小
  --tx-rate=N                   废弃，改用 --rate [0]
  --max-requests=N             废弃，改用 --events [0]
  --max-time=N                 废弃，改用 --time [0]
  --num-threads=N              废弃，改用 --threads [1]
```

* 数据库连接选项

```shell
mysql options:              # MySQL 数据库专用选项
  --mysql-host=[LIST,...]          MySQL server host [localhost]
  --mysql-port=[LIST,...]          MySQL server port [3306]
  --mysql-socket=[LIST,...]        MySQL socket
  --mysql-user=STRING              
  --mysql-password=STRING         
  --mysql-db=STRING               
  --mysql-ssl[=on|off]             
  --mysql-ssl-cipher=STRING       
  --mysql-compression[=on|off]     
  --mysql-debug[=on|off]          
  --mysql-ignore-errors=[LIST,...] 
  --mysql-dry-run[=on|off]         

pgsql options:              # PostgreSQL 数据库专用选项
  --pgsql-host=STRING     
  --pgsql-port=N          
  --pgsql-user=STRING     
  --pgsql-password=STRING 
  --pgsql-db=STRING       
```

### 脚本

> 默认放在/usr/share/sysbench/，有如下脚本：

```shell
[root@zabbix4 yum.repos.d]# ll /usr/share/sysbench/
total 136
-rwxr-xr-x 1 root root  1452 Jan 14 18:42 bulk_insert.lua
-rw-r--r-- 1 root root 14369 Jan 14 18:42 oltp_common.lua
-rwxr-xr-x 1 root root  1290 Jan 14 18:42 oltp_delete.lua
-rwxr-xr-x 1 root root  2415 Jan 14 18:42 oltp_insert.lua
-rwxr-xr-x 1 root root  1265 Jan 14 18:42 oltp_point_select.lua
-rwxr-xr-x 1 root root  1649 Jan 14 18:42 oltp_read_only.lua
-rwxr-xr-x 1 root root  1824 Jan 14 18:42 oltp_read_write.lua
-rwxr-xr-x 1 root root  1118 Jan 14 18:42 oltp_update_index.lua
-rwxr-xr-x 1 root root  1127 Jan 14 18:42 oltp_update_non_index.lua
-rwxr-xr-x 1 root root  1440 Jan 14 18:42 oltp_write_only.lua
-rwxr-xr-x 1 root root  1919 Jan 14 18:42 select_random_points.lua
-rwxr-xr-x 1 root root  2118 Jan 14 18:42 select_random_ranges.lua
-rwxr-xr-x 1 root root 12320 Jan 14 18:42 tpcc_check.lua
-rwxr-xr-x 1 root root 20684 Jan 14 18:42 tpcc_common.lua
-rwxr-xr-x 1 root root  2001 Jan 14 18:42 tpcc.lua
-rwxr-xr-x 1 root root 28512 Jan 14 18:42 tpcc_run.lua
```

### 测试


这里仅做数据库测试，其他测试可以是用sysbench –help，sysbench cpu help等查看相应参数。

* **建测试表及数据**：

```shell
sysbench oltp_read_write.lua --time=60 --mysql-host=192.168.100.127 --mysql-port=3506 --mysql-user=test --mysql-password=123456 --mysql-db=pcms --table-size=10000 --tables=2 --threads=2 prepare
```

* **测试数据**：

```shell
sysbench oltp_read_write.lua --time=60 --mysql-host=192.168.100.127 --mysql-port=3506 --mysql-user=test --mysql-password=123456 --mysql-db=pcms --table-size=10000 --tables=2 --threads=2 run
```

* **清洗数据**：
```shell
sysbench oltp_read_write.lua --time=60 --mysql-host=192.168.100.127 --mysql-port=3506 --mysql-user=test --mysql-password=123456 --mysql-db=pcms --table-size=10000 --tables=2 --threads=2 cleanup
```
