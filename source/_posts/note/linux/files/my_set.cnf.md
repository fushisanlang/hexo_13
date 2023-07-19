---
title: my_set.cnf
date: 2016-11-27
updated: 2016-11-28
tags:
  - mysql
categories:
  - file
abbrlink: cbad4e32
---
```
[mysqld]
########basic settings########
user=mysql
datadir = /data/mysql
transaction_isolation = READ-COMMITTED
explicit_defaults_for_timestamp = 1
port = 3306
server_id = 64
socket = /tmp/mysql.sock
#sql_mode = 
"STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION,NO_ZERO_DATE,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER"
########log settings##########
log-bin=mysql-bin
expire_logs_days = 10
log-error = /data/mysql/log/error.log
long_query_time = 2
log-queries-not-using-indexes = 1
slow_query_log = 1
slow_query_log_file = /data/mysql/log/slowquery.log
#general_log                    = 1                                 
#general_log_file               = /data/mysql/log/mysql-general.log
log_throttle_queries_not_using_indexes = 10
########innodb settings########
#索引和数据缓冲区大小，一般设置物理内存的60%-70%
innodb_buffer_pool_size=4G
innodb_buffer_pool_instances = 8
innodb_buffer_pool_load_at_startup = 1
innodb_buffer_pool_dump_at_shutdown = 1
innodb_page_size = 8192
innodb_lock_wait_timeout = 5
innodb_file_format = Barracuda
innodb_file_format_max = Barracuda
innodb_purge_threads = 4
innodb_large_prefix = 1
innodb_print_all_deadlocks = 1
innodb_strict_mode = 1
innodb_sort_buffer_size = 67108864 
#默认值为 48M. 有很高写入吞吐量
innodb_log_file_size=2G
#InnoDB 存储引擎的事务日志所使用的缓冲区
innodb_log_buffer_size = 16M
#关键参数，0代表大约每秒写入到日志并同步到磁盘，数据库故障会丢失1秒左右事务数据。1为每执行一条SQL后写入到日志并同步到磁
盘，I/O开销大，执行完SQL要等待日志读写，效率低。2代表只把日志写入到系统缓存区，再每秒同步到磁盘，效率很高，如果服务器故
障，才会丢失事务数据。对数据安全性要求不是很高的推荐设置2，性能高，修改后效果明显。
innodb_flush_log_at_trx_commit=2
#修改InnoDB为独立表空间模式,每个数据库的每个表都会生成一个数据空间
innodb_file_per_table=1
#限制Innodb能打开的表的数据
innodb_file_io_threads=4
#如果使用硬件RAID磁盘控制器, 需要设置为 O_DIRECT
innodb_flush_method=O_DIRECT
#设置会影响InnoDB每秒在后台执行多少操作
innodb_io_capacity=800
innodb_io_capacity_max=1000
#这个参数必须要和innodb_io_capacity设置一样
innodb_lru_scan_depth=800
#限制了一次有多少线程能进入内核,0表示不限制进入内核的数量
innodb_thread_concurrency = 64
#除了缓存表数据和索引外,可以为操作所需的其他内部项分配缓存来提升InnoDB的性能,这些内存就可以通过此参数来分配
innodb_additional_mem_pool_size=16M
#修改为基于行的复制
innodb_autoinc_lock_mode = 2
##############cache#############
max_allowed_packet = 32M
#内部内存临时表的最大值
tmp_table_size = 64M
tmpdir = /tmp
collation_server = utf8_general_ci
character_set_server = utf8
#即跳过外部锁定
skip-external-locking
skip-name-resolve
#MySQL能暂存的连接数量(根据实际设置)
back_log=512
#指定索引缓冲区的大小,只对MyISAM表起作用,这里写上也没有关系
key_buffer_size=128M
#这条指令限定用于每个数据库线程的栈大小
thread_stack=256k
#当一个查询不断地扫描某一个表,MySQL会为它分配一段内存缓冲区
read_buffer_size=16M
#线程缓存
thread_cache_size=64
#查询缓存大小
query_cache_size=128M
#内部内存临时表的最大值,每个线程都要分配
max_heap_table_size=64M
#将查询结果放入查询缓存中
query_cache_limit = 2M
query_cache_min_res_unit = 2k
bulk_insert_buffer_size = 64M
query_cache_type=1
#代表在事务过程中容纳二进制日志SQL语句的缓存大小
binlog_cache_size = 2M
#同样是缓存表大小
table_open_cache=128
#缓存线程
#thread_cache=16000
#推荐设置为服务器 CPU核数的2倍
thread_concurrency=24
interactive_timeout=1800
wait_timeout=1800
#表和表联接的缓冲区的大小
join_buffer_size = 128M
#是一个connection级参数,在每个connection第一次需要使用这个buffer的时候,一次性分配设置的内存
sort_buffer_size = 8M
#随机读取数据缓冲区使用内存
read_rnd_buffer_size = 16M
##################################################
#connect 是一个MySQL中与安全有关的计数器值,它负责阻止过多尝试失败的客户端以防止暴力破解密码
max-connect-errors=10000
#连接数
max-connections=1000
skip_name_resolve = 1
##################################################
#开启查询缓存
explicit_defaults_for_timestamp=true
###################################################
# xtradb cluster settings
binlog_format = ROW
wsrep_cluster_name = PXC
wsrep_cluster_address = gcomm://192.168.1.76,192.168.1.73,192.168.1.74,192.168.1.64,192.168.1.65
wsrep_node_address = 192.168.1.64
wsrep_provider = /usr/lib64/libgalera_smm.so
wsrep_sst_method = rsync
innodb_locks_unsafe_for_binlog = 1
innodb_autoinc_lock_mode = 2
default_storage_engine=InnoDB
wsrep_provider_options="gcache.size=4G"
wsrep_slave_threads=8
```
