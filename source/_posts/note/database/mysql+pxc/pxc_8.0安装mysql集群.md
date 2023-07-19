---
title: pxc 8.0安装mysql集群
date: 2019-3-17
updated: 2019-3-18
tags:
  - pxc
  - mysql
categories:
  - note
abbrlink: 60c6c8ab
---



### 环境介绍

* pxc版本：[Percona-XtraDB-Cluster-8.0.18-r167-el7-x86_64-bundle.tar](https://www.percona.com/downloads/Percona-XtraDB-Cluster-LATEST/)

* 服务器：

	ip|os|hostname
	-|-|-
	192.168.92.131|CentOS Linux release 7.8.2003 (Core)  x86_64 |node1
	192.168.92.132|CentOS Linux release 7.8.2003 (Core)  x86_64 |node2
	192.168.92.133|CentOS Linux release 7.8.2003 (Core)  x86_64 |node3

* 防火墙： 关闭firewalld和selinux

### 安装

```shell
#安装开发环境
yum clean all
yum -y groupinstall Development tools

#安装yum源
yum install epel-*
yum install http://www.percona.com/downloads/percona-release/redhat/0.1-3/percona-release-0.1-3.noarch.rpm -y  #这个命令安装的是5.6版本的pxc源，但是实际使用中，8.0版本也适用。主要是用来安装qpress

#安装常用工具
yum install gcc c++ zip unzip man vim telnet wget nethogs htop glances dstat traceroute lrzsz goaccess ntpdate dos2unix openssl-devel xinetd lvm2 #有些工具，比如telnet不是pxc安装所需，但是后期运维时可能会用得上，所以一并安装

#安装pxc
yum install socat libev -y

#从官网下载相应压缩包，包中包含所需的rpm包
mkdir /soft/pxc -p
tar xc Percona-XtraDB-Cluster-8.0.18-r167-el7-x86_64-bundle.tar -C /soft/pxc 
cd /soft/pxc
yum install *.rpm
#在安装时，可能会有gpgcheck告警导致安装异常，我在安装过程中直接关闭了相关检查。如果认为此法不安全可以通过其他方式安装gpress后，安装相应rpm即可。
```



### 初始化

```shell
systemctl start mysql
grep 'temporary password' /var/log/mysqld.log #获取临时密码
mysql_secure_installation #安全初始化
mysql -p #登录验证服务是否正常
```



### 集群配置

```shell
systemctl stop mysql
vim /etc/my.cnf #相关配置示例及说明见附1，可以自行修改。注意不同节点的node配置要不同
```



### 主节点启动

```shell
systemctl start  mysql@bootstrap.service
```



### 其余节点启动

```shell
systemctl start mysql
```



### 验证

```sql
mysql>  show status like 'wsrep_cluster_size%';
+--------------------+-------+
| Variable_name      | Value |
+--------------------+-------+
| wsrep_cluster_size | 3     |
+--------------------+-------+
1 row in set (0.01 sec)

-- 这里还有很多参数，可以通过  show status like 'wsrep%'; 来查看，此处是为了示例，单独查看的集群节点个数

mysql> create database test_pxc;  --在其中一个节点创建一个叫test_pxc的数据库，在其他节点中也会有新的数据库被创建。
mysql> drop database test_pxc; --同样的，删除操作也会被同步。
```



### 后续

> 示例的配置文件，只是为了达到集群同步而配置的简单配置文件，相应的mysql优化及集群同步相关优化均未配置，如果用于生产，需要根据情况进行优化配置。
>
> 相应配置参数说明，可以在pxc的官网查到。



### 附1：my.cnf

```shell
# Template my.cnf for PXC
# Edit to your requirements.
[client]
socket=/var/lib/mysql/mysql.sock

[mysqld]
server-id=1
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid

# Binary log expiration period is 604800 seconds, which equals 7 days
binlog_expire_logs_seconds=604800

######## wsrep ###############
# Path to Galera library
wsrep_provider=/usr/lib64/galera4/libgalera_smm.so

# Cluster connection URL contains IPs of nodes
#If no IP is found, this implies that a new cluster needs to be created,
#in order to do that you need to bootstrap this node
wsrep_cluster_address=gcomm://192.168.92.131,192.168.92.132,192.168.92.133

# In order for Galera to work correctly binlog format should be ROW
binlog_format=ROW

# Slave thread to use
wsrep_slave_threads=8

wsrep_log_conflicts

# This changes how InnoDB autoincrement locks are managed and is a requirement for Galera
innodb_autoinc_lock_mode=2

# Node IP address
wsrep_node_address=192.168.92.131
# Cluster name
wsrep_cluster_name=13_test_pxc

#If wsrep_node_name is not specified,  then system hostname will be used
wsrep_node_name=pxc-cluster-node-1

#pxc_strict_mode allowed values: DISABLED,PERMISSIVE,ENFORCING,MASTER
pxc_strict_mode=ENFORCING

# SST method
wsrep_sst_method=xtrabackup-v2
wsrep_provider_options="socket.ssl_key=server-key.pem;socket.ssl_cert=server-cert.pem;socket.ssl_ca=ca.pem"
```