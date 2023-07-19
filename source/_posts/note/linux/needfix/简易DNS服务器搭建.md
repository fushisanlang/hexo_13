---
title: 简易DNS服务器搭建
date: 2017-6-26
updated: 2017-6-27
categories:
  - note
tags:
  - DNS
abbrlink: '675265e9'
---
# 简易DNS服务器搭建

***



### 环境介绍

系统：centos6.7 

IP：192.168.122.101

防火墙：关闭 selinux 和 iptables



### 软件安装

```shell
rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm  #安装epel源
yum install bind -y #用于建立DNS的软件
yum install 32:bind-utils-9.8.2-0.68.rc1.el6.x86_64 -y #dig工具
```



### DNS搭建

```shell
cp /etc/named.conf /etc/named.conf.default

vim /etc/named.conf
    options {
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
        allow-query     { any; };
        recursion yes;
        allow-transfer  { none; };
    };
    
    zone "." IN {
        type hint;
        file "named.ca";
    };
    zone "rong.lian" IN {
        type master;
        file "named.rong.lian";
    };
    zone "100.168.192.in-addr.arpa" IN {
        type master;
        file "named.192.168.122";
    };
    
vim /var/named/named.rong.lian
    $TTL    600
    @                       IN SOA   master.rong.lian. name.www.rong.lian. (2011080401 3H 15M 1W 1D ) ;
    @                       IN NS    master.rong.lian.  ; DNS 伺服器名稱
    master.rong.lian.    IN A     192.168.122.101         ; DNS 伺服器 IP
    @                       IN MX 10 www.rong.lian.     ; 領域名稱的郵件伺服器
    
    www.rong.lian.       IN A     192.168.122.101
    
    102.rong.lian.       IN A    192.168.122.102
    103.rong.lian.       IN A    192.168.122.103;
    
vim /var/named/named.192.168.122
    $TTL    600
    @       IN SOA  master.rong.lian. name.www.rong.lian. (2011080401 3H 15M 1W 1D )
    @       IN NS   master.rong.lian.
    101     IN PTR  master.rong.lian.  ; 將原本的 A 改成 PTR 的標誌而已
    
    101     IN PTR  www.rong.lian.     ; 這些是特定的 IP 對應
    
    102     IN PTR  102.rong.lian.  ;
    103     IN PTR  103.rong.lian.
    
/etc/init.d/named  start
netstat -utlnp | grep named
chkconfig named on
tail -n 30 /var/log/messages | grep named
```



### 测试

```shell
vim /etc/resolv.conf
	nameserver 192.168.122.101  #第一行添加
	
dig 102.rong.lian
```

