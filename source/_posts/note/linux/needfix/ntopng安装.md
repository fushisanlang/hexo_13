---
title: ntopng安装
date: 2018-10-17
updated: 2018-10-18
categories:
  - note
abbrlink: 9b44f28
---
## ntopng安装

### 环境介绍

centos6.7（64位）关闭seliunux和防火墙
内核版本 2.6.32-573.el6.x86_64
ip地址 192.168.122.101 192.168.122.102 192.168.122.103 


### 环境准备
```shell
ntopng-2.4-stable.tar.gz 
rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm 
ntpdate ntp1.aliyun.com
```

### 软件安装
```shell
mkdir /soft -p 
yum install autoconf autogen automake gcc-c++ GeoIP-devel glib2-devel hiredis-devel libcurl-devel libodb-mysql-devel.x86_64 libpcap-devel libtool libxml2-devel mysql-devel.x86_64 mysql++-devel.x86_64 mysql-embedded-devel.x86_64 mysql-proxy-devel.x86_64 redis soci-mysql-devel.x86_64 sqlite-devel subversion wget git

tar xf ntopng-2.4-stable.tar.gz -C /soft
cd /soft/ntopng-2.4-stable
sh autogen.sh 
./configure --with-pic 
make geoip
make
```
### 软件配置
```shell
mkdir /etc/ntopng -p 
vim /etc/ntopng/ntopng.conf 
-G=/var/run/ntopng.pid
vim /etc/ntopng/ntopng.start
--local-networks "192.168.6.133/32"
--interface 1
sh /soft/ntopng-2.4-stable/ntopng 
```


```shell
cd /etc/yum.repos.d/
wget http://packages.ntop.org/centos-stable/ntop.repo -O ntop.repo
rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
wget https://copr.fedoraproject.org/coprs/saltstack/zeromq4/repo/epel-6/saltstack-zeromq4-epel-6.repo
rpm -ivh http://packages.ntop.org/rpm6/extra/hiredis-0.10.1-3.el6.x86_64.rpm http://packages.ntop.org/rpm6/extra/hiredis-devel-0.10.1-3.el6.x86_64.rpm
yum erase zeromq3 (Do this once to make sure zeromq3 is not installed)
yum clean all
yum update
yum install   ntopng ntopng-data cento
```