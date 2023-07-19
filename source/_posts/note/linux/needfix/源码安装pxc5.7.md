---
title: 源码安装pxc5
date: 2018-10-11
updated: 2018-10-12
categories:
  - note
abbrlink: 89adca3d
---

# 源码安装pxc5.7

### 背景介绍

接到通知，需要在现有pxc集群的主机上，部署另一套pxc集群，使两套pxc集群共存。

普通rpm安装的方式无法达到要求，所以考虑使用源码安装的方式，进行第二个集群的安装。



### 环境介绍

* 服务器：

以下三个服务器，均通过rpm方式安装了pxc8，具体安装方法见  [pxc 8.0安装mysql集群](./pxc 8.0安装mysql集群.md)

| ip             | os                                           | hostname |
| -------------- | -------------------------------------------- | -------- |
| 192.168.92.131 | CentOS Linux release 7.8.2003 (Core)  x86_64 | node1    |
| 192.168.92.132 | CentOS Linux release 7.8.2003 (Core)  x86_64 | node2    |
| 192.168.92.133 | CentOS Linux release 7.8.2003 (Core)  x86_64 | node3    |

* 防火墙： 关闭firewalld和selinux



### 基础文件准备

```shell
#上传文件 因为多数文件都在外网，下载一次要好久，故使用本地文件

mkdir /soft/pxc_5.7 -p
ls /soft/pxc_5.7

-rw-r--r--  1 root root 83709983 8月   5 14:27 boost_1_59_0.tar.gz
-rw-r--r--  1 root root   294756 12月  8 2016 compat-readline5-5.2-27.el7.psychotic.x86_64.rpm
-rw-r--r--  1 root root  8518916 6月  14 2018 percona-xtrabackup-24-2.4.12-1.el6.x86_64.rpm
-rw-r--r--  1 root root 75133862 10月  2 2018 Percona-XtraDB-Cluster-5.7.23-31.31.tar.gz

mkdir /soft/pxc_5.7 -p
ls /soft/pxc_5.7

-rw-r--r--  1 root root 83709983 8月   5 14:27 boost_1_59_0.tar.gz
-rw-r--r--  1 root root   294756 12月  8 2016 compat-readline5-5.2-27.el7.psychotic.x86_64.rpm
-rw-r--r--  1 root root  8518916 6月  14 2018 percona-xtrabackup-24-2.4.12-1.el6.x86_64.rpm
-rw-r--r--  1 root root 75133862 10月  2 2018 Percona-XtraDB-Cluster-5.7.23-31.31.tar.gz
```



### 安装依赖

```shell
yum install -y vim target socat scons redhat-lsb readline-devel protobuf popt-static popt-devel perl-Time-HiRe perl-DBD-mysql pam-devel openssl-devel numactl ncurses-devel libtool libstdc++-devel libodb-boost-devel libnl-devel libnfnetlink-devel libnfnetlink libgcrypt-devel libev-devel libev libcurl* libaio-devel libaio kernel-devel ipvsadm iptraf gperftools-devel git gcc-c++ gcc cmake check-devel check Built boost-devel bison automake autoconf asio-devel

cd /soft/pxc_5.7
#wget http://packages.psychotic.ninja/7/testing/x86_64/RPMS/compat-readline5-5.2-27.el7.psychotic.x86_64.rpm
#使用本地文件
yum install compat-readline5-5.2-27.el7.psychotic.x86_64.rpm percona-xtrabackup-24-2.4.12-1.el6.x86_64.rpm
```



### 编译安装pxc5.7

```shell
#编译libgalera_smm.so
tar xf Percona-XtraDB-Cluster-5.7.23-31.31.tar.gz 
cd Percona-XtraDB-Cluster-5.7.23-31.31
cd percona-xtradb-cluster-galera
scons -j4 psi=1 --config=force   revno=    libgalera_smm.so

#编译pxc
cd ..
cp /soft/pxc_5.7/boost_1_59_0.tar.gz . #将boost压缩包放到源码路径即可，编译时会自动解压

mkdir build
cd build

CHOST="x86_64-pc-linux-gnu" CFLAGS="-march=nocona -O2 -pipe" CXXFLAGS="-march=nocona -O2 -pipe" \
 cmake ../  \
 -DMYSQL_USER=mysql \
 -DCMAKE_BUILD_TYPE:STRING=Release \
 -DBUILD_CONFIG=mysql_release \
 -DWITH_EMBEDDED_SERVER=OFF \
 -DFEATURE_SET=community \
 -DENABLE_DTRACE=OFF \
 -DWITH_SSL=system \
 -DWITH_ZLIB=system  \
 -DCMAKE_INSTALL_PREFIX=/usr/local/mysql_5.7\
 -DMYSQL_SERVER_SUFFIX=-29.22 \
 -DWITH_INNODB_DISALLOW_WRITES=ON \
 -DWITH_WSREP=ON \
 -DWITH_UNIT_TESTS=0 \
 -DWITH_READLINE=system \
 -DWITHOUT_TOKUDB=ON \
 -DWITHOUT_ROCKSDB=ON \
 -DWITH_PAM=ON \
 -DWITH_INNODB_MEMCACHED=ON \
 -DDOWNLOAD_BOOST=1 \
 -DWITH_BOOST=..\
 -DWITH_SCALABILITY_METRICS=ON \
 -DCMAKE_EXE_LINKER_FLAGS="-ltcmalloc" \
 -DWITH_SAFEMALLOC=OFF  \
 -DWITHOUT_BLACKHOLE_STORAGE_ENGINE=1 \
 -DWITHOUT_FEDERATED_STORAGE_ENGINE=1 \
 -DWITHOUT_ARCHIVE_STORAGE_ENGINE=1

make -j $CPUcount
make install
```



### 配置

```shell
cd ..
cp percona-xtradb-cluster-galera/libgalera_smm.so /usr/local/mysql_5.7/lib/

ln -sv /usr/local/mysql_5.7/bin/* /usr/local/bin/
mkdir -p /data/database/mysql
chown mysql:mysql -R /data/database/mysql

#让mysqld支持tcmalloc
cd /usr/local/mysql_5.7
sed -i '/Initialize script globals/ a export LD_PRELOAD=/usr/local/lib/libtcmalloc.so' bin/mysqld_safe
```



### 编辑配置文件

```shell
vim /etc/my.cnf_5.7 #具体文件见附三
```



### 初始化实例

```shell
/usr/local/mysql_5.7/bin/mysqld --initialize --datadir=/data/database/mysql/ --basedir=/usr/local/mysql_5.7/ --user=mysql
```



### 启动主节点

```shell
/usr/local/mysql_5.7/bin/mysqld_safe --defaults-file=/etc/my.cnf_5.7 --wsrep-new-cluster --lc_messages_dir=/usr/local/mysql_5.7/share/ --lc_messages=en_US &
```



### 配置用户

```sql
-- mysql实例化初始之后，会生成临时密码记录在error文件中，初次连接后建议马上修改
-- sst同步时，需要一个账户和密码，并配置到配置文件的wsrep_sst_auth配置项，我这里偷懒用了root用户，生产中绝不可如此使用。建议单独简历一个账户用来同步，sql语句如下：
mysql> CREATE USER 'sstuser'@'localhost' IDENTIFIED BY 's3cret';
mysql> GRANT RELOAD, LOCK TABLES, PROCESS, REPLICATION CLIENT ON *.* TO 'sstuser'@'localhost';
mysql> FLUSH PRIVILEGES;
-- 以上用户只需要在主节点配置即可
```



### 启动普通节点

```shell
/usr/local/mysql_5.7/bin/mysqld_safe --defaults-file=/etc/my.cnf_5.7 --lc_messages_dir=/usr/local/mysql_5.7/share/ --lc_messages=en_US &
```



### 后续

```shell
# 上述步骤之后，即达到了一个服务器集群部署多个不同pxc集群实例的需求。
# 但是除了最初通过yum不是的pxc示例可以通过systemctl托管外，其他服务都是通过mysqld_safe命令直接启动，不方便管理。如果生产中实际使用，可以考虑通过systemctl或者mysqld_multi来管理多实例
```



### 附一：pxc集群环境所需端口整理

```shell
pxc环境所涉及的端口及配置项：

#MySQL实例端口
#Regular MySQL port, default 3306.   
port=3306

#pxc cluster相互通讯的端口
#Port for group communication, default 4567. It can be changed by the option: 
wsrep_provider_options ="gmcast.listen_addr=tcp://0.0.0.0:4010; "

#用于SST传送的端口
#Port for State Transfer, default 4444. It can be changed by the option: 
wsrep_sst_receive_address=10.11.12.205:5555

#用于IST传送的端口
#Port for Incremental State Transfer, default port for group communication + 1 (4568). It can be changed by the option: 
wsrep_provider_options = "ist.recv_addr=10.11.12.206:7777; "
```



### 附二：pxc名词解释

```shell
WS：write set 写数据集
IST: Incremental State Transfer 增量同步
SST：State Snapshot Transfer 全量同步 
```



### 附三 ：my.cnf_5.7

```cnf
# 配置文件：
[client]
port=13306
socket = /tmp/mysql_5.7.sock
[mysqld]
server-id=132
port=13306
datadir=/data/database/mysql
tmpdir=/data/database/mysql
#basedir=/usr/local/mysql_5.7
socket = /tmp/mysql_5.7.sock
log-error=/data/database/mysql/thai_pxc_cluster.err
pid-file=/data/database/mysql/thai_pxc_cluster.pid
user=mysql
secure_file_priv = ""
performance_schema_max_table_instances=50000
table_definition_cache=400
table_open_cache=1024
# General
back_log=2000
connect_timeout=15
max_connections=1024
max_allowed_packet = 16M
max_heap_table_size = 128M
sort_buffer_size =  8M
net_buffer_length = 8K
read_buffer_size = 8M
read_rnd_buffer_size = 32M
query_cache_size = 128M
join_buffer_size=8M
bulk_insert_buffer_size=128M
concurrent_insert=2
delay_key_write=ON
delayed_insert_limit=4000
delayed_insert_timeout=600
delayed_queue_size=4000
tmp_table_size = 256M
thread_cache_size=120
character-set-server=utf8
metadata_locks_hash_instances=256
open-files-limit = 10240
skip-name-resolve
core_file
transaction-isolation=READ-COMMITTED
sql_mode = ""
# Innodb
innodb_buffer_pool_size = 4096M
innodb_buffer_pool_instances=8
innodb_log_file_size = 1024M
innodb_log_buffer_size = 16M
innodb_lock_wait_timeout = 20
innodb_autoinc_lock_mode=2
innodb_read_io_threads = 5
innodb_write_io_threads = 5
innodb_thread_concurrency = 8
innodb_doublewrite=1
innodb_flush_log_at_trx_commit = 2
innodb_flush_method = 'O_DIRECT'
innodb-page-cleaners=8
innodb_purge_threads=4
innodb_lru_scan_depth=2048
innodb_io_capacity=8000
innodb_io_capacity_max=16000
innodb_adaptive_hash_index=OFF
innodb-change-buffering=none
innodb_flush_neighbors=0
innodb_max_dirty_pages_pct = 90
innodb_max_dirty_pages_pct_lwm = 10
# Binlog
relay-log=relay-1
binlog_format=ROW
enforce-gtid-consistency
gtid-mode=on
master-info-repository=TABLE
relay-log-info-repository=TABLE
binlog-checksum=NONE
log-bin=mysql-bin
max-binlog-size=128M
log_slave_updates
expire_logs_days=3
sync_binlog=1
binlog_cache_size = 4M
log_output=FILE
slow_query_log=1
slow_query_log_file=/data/database/mysql/slowquery.log
max_slowlog_size=1024m
max_slowlog_files=10
long_query_time=1
# Monitoring
innodb_monitor_enable='%'
performance_schema=ON
performance_schema_instrument='%synch%=on'
# Galera
symbolic-links=0
explicit_defaults_for_timestamp=true
#wsrep_provider=/usr/lib64/galera3/libgalera_smm.so
wsrep_provider=/usr/local/mysql_5.7/lib/libgalera_smm.so
wsrep_cluster_address=gcomm://192.168.92.131:14567,192.168.92.135:14567
default_storage_engine=InnoDB
wsrep_slave_threads= 20
wsrep_log_conflicts
wsrep_cluster_name=pxc_cluster
wsrep_node_name=pxc_node_131
wsrep_node_address=192.168.92.131:13306
wsrep_node_incoming_address=192.168.92.131:13306
wsrep_sst_method=xtrabackup-v2
wsrep_sst_auth="root:yierer333"
pxc_strict_mode=DISABLED
wsrep_sst_receive_address=192.168.92.131:14444 #default 4444
wsrep_provider_options ="gmcast.listen_addr=tcp://192.168.92.131:14567;ist.recv_addr=192.168.92.131:14568; " #default 4567 4567+1 = 4568
```

