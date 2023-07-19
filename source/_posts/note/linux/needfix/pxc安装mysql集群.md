---
title: pxc安装mysql集群
date: 2019-10-4
updated: 2019-10-5
categories:
  - note
abbrlink: 942b5025
---
## PXC搭建

1. 环境说明   
   test1 ：192.168.26.136
   test2 ：192.168.26.145   
   两个节点均关闭iptables，seliunx的级别设为Permissive
2. 软件安装


```shell
rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
yum install http://www.percona.com/downloads/percona-release/redhat/0.1-3/percona-release-0.1-3.noarch.rpm -y    ##这两条命令是安装yum源
yum install socat -y
yum install Percona-XtraDB-Cluster-56  -y    #这两条命令是安装软件包
```

3. 创建所需目录
```shell
mkdir -p /data/mysql/log
chown mysql:mysql /data/mysql/log
```

4. 初始化数据库
```shell
mysql_install_db --user=mysql --datadir=/data/mysql
/etc/init.d/mysql start
mysql_secure_installation    #安全初始化
```

5. 配置node1
```shell     
vim /etc/my.cnf
   
   [mysqld]
   datadir=/var/lib/mysql
   socket=/var/lib/mysql/mysql.sock

   # xtradb cluster settings
   binlog_format = ROW
   wsrep_cluster_name = PXCqwe
   wsrep_cluster_address = gcomm://192.168.26.133,192.168.26.145
   wsrep_node_address = 192.168.26.133
   wsrep_provider = /usr/lib64/libgalera_smm.so
   wsrep_sst_method = rsync
   wsrep_sst_method=xtrabackup-v2
   wsrep_sst_auth=root:qwe123
   innodb_locks_unsafe_for_binlog = 1
   innodb_autoinc_lock_mode = 2
   default_storage_engine=InnoDB
   wsrep_provider_options="gcache.size=2G"
   wsrep_slave_threads=8
   server_id = 133
```

6. 启动node1   
```shell
service mysql bootstrap-pxc 
mysql>show global status like 'wsrep%';
    | wsrep_cluster_size           | 1   | 
    | wsrep_incoming_addresses     | 192.168.2.200:3306 
    ##有如上显示说明第一个节点启动成功
```
7. 添加新的 Node 到Cluster中   
```shell
vim /etc/my.cnf
   [mysqld]
   datadir=/var/lib/mysql
   socket=/var/lib/mysql/mysql.sock

    # xtradb cluster settings
   binlog_format = ROW
   wsrep_cluster_name = PXCqwe
   wsrep_cluster_address = gcomm://192.168.26.133,192.168.26.145
   wsrep_node_address = 192.168.26.145
   wsrep_provider = /usr/lib64/libgalera_smm.so
   wsrep_sst_method = rsync
   wsrep_sst_method=xtrabackup-v2
   wsrep_sst_auth=root:qwe123
   innodb_locks_unsafe_for_binlog = 1
   innodb_autoinc_lock_mode = 2
   default_storage_engine=InnoDB
   wsrep_provider_options="gcache.size=2G"
   wsrep_slave_threads=8
   server_id = 145

service mysql start

    mysql>show global status like ‘wsrep%‘;
    | wsrep_incoming_addresses     | 192.168.2.200:3306,192.168.2.201:3306  |
    | wsrep_cluster_size           | 2                                    |
```

* 测试

在某一节点操作数据库，在另一节点查看是否同步操作即可



 


