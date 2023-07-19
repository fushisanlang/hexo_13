---
title: mysql双主+keepalived
date: 2016-12-22
updated: 2016-12-23
tags:
  - mysql
  - keepalived
categories:
  - note
abbrlink: 812e902b
---



# mysql双主+keepalived



## 环境介绍

节点|ip|系统|mysql版本|keepalived版本|备注
:-:|:-:|:-:|:-:|:-:|:-:
1|172.20.10.1|rhel 7.4 x86_64|5.7.28|2.0.19|关闭selinux和firewalld
2|172.20.10.2|rhel 7.4 x86_64|5.7.28|2.0.19|关闭selinux和firewalld
3|172.20.10.3|-| - |-|vip



## 安装配置mysql



### 安装mysql

采用 `yum` 方式安装。具体操作步骤如下：

本步 `node1`，`node2`都执行相同操作。

```shell
#创建软件包存放目录
mkdir /soft -p

#安装mysql
cd /soft
wget https://repo.mysql.com/mysql80-community-release-el7-3.noarch.rpm
rpm -ivh mysql80-community-release-el7-3.noarch.rpm
cd /etc/yum.repos.d/
vim  mysql-community.repo
	#配置需要版本的yum源打开，默认为mysql8
yum install mysql-server mysql
```



### 配置mysql

主主集群需要配置两个节点间互为主从。除非特殊声明，`node1`，`node2`都执行相同操作。

```shell
vim /etc/my.cnf
	datadir=/data/mysql #修改mysql的存储路径
	server-id = 1 #添加节点id，此处两节点应不同      
	log-bin = mysql-bin     
	sync_binlog = 1
	binlog_checksum = none
	binlog_format = mixed
	auto-increment-increment = 2     
	auto-increment-offset = 1    
	slave-skip-errors = all      

mkdir -p /data/mysql
chown mysql.mysql /data/mysql 
systemctl restart mysql #修改配置后重启服务

#yum安装后，mysql5.7的初始密码保存在mysql的error日志中。默认位置为/var/log/mysqld.log
grep 'temporary password' /var/log/mysqld.log
mysql_secure_installation #修改mysql密码并完成初始化
mysql -p #使用修改后的密码登陆数据库
```

```mysql
> grant replication slave,replication client on *.* to repl@'%' identified by '123456'; #创建一个用来同步的用户
> flush privileges; #刷新权限
> flush tables with read lock; #锁表，待同步配置完成再解锁
```

* #### `node1` 操作

```mysql
> show master status; #查看当前节点状态
```

* #### `node2` 操作

```mysql
> unlock tables;     #先解锁，将对方数据同步到自己的数据库中
> stop slave;
> change  master to master_host='172.20.10.1',master_user='repl',master_password='123456',master_log_file='mysql-bin.000001',master_log_pos=150;  #根据实际情况修改参数
> start slave;
> show slave status \G; #查看两个线程状态是否为YES 
# Slave_IO_Running: Yes
# Slave_SQL_Running: Yes

> flush tables with read lock; #检查无误后将表锁起，准备另一个节点
> show master status; #查看当前节点状态
```

* #### `node1`操作
```mysql
> unlock tables;     #先解锁，将对方数据同步到自己的数据库中
> stop slave;
> change  master to master_host='172.20.10.2',master_user='repl',master_password='123456',master_log_file='mysql-bin.000001',master_log_pos=150; #根据实际情况修改参数
> start slave;
> show slave status \G; #查看两个线程状态是否为YES 
# Slave_IO_Running: Yes
# Slave_SQL_Running: Yes
```

* #### `node2` 操作

```mysql
> unlock tables;  #将表解锁
```

上述操作之后，mysql双主配置完毕。可以连接两个节点，验证集群是否可用。



## 安装配置keepalived

### 安装keepalived

采用 编译方式安装。具体操作步骤如下：

本步 `node1`，`node2`都执行相同操作。

```shell
cd /soft
wget https://www.keepalived.org/software/keepalived-2.0.19.tar.gz
tar xf keepalived-2.0.19.tar.gz
cd keepalived-2.0.19
./configure
make && make install
#上述编译安装时，可能发生确实依赖的情况
yum install -y openssl-devel
cp /soft/keepalived-2.0.19/keepalived/etc/init.d/keepalived /etc/rc.d/init.d/
cp /usr/local/keepalived/etc/sysconfig/keepalived /etc/sysconfig/
mkdir /etc/keepalived/
cp /usr/local/keepalived/etc/keepalived/keepalived.conf  /etc/keepalived/
cp /usr/local/keepalived/sbin/keepalived  /usr/sbin/
systemctl enable keepalived
```



### 配置keepalived

```shell
cp /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.bak
vim /etc/keepalived/keepalived.conf
```
* #### `node1` 配置

```
! Configuration File for keepalived

global_defs {
    router_id MASTER-HA
}

vrrp_script chk_mysql_port { #检测mysql服务是否在运行。有很多方式，比如进程，用脚本检测等等
    script "/opt/chk_mysql.sh" #这里通过脚本监测
    interval 2 #脚本执行间隔，每2s检测一次
    weight -5 #脚本结果导致的优先级变更，检测失败（脚本返回非0）则优先级 -5
    fall 2 #检测连续2次失败才算确定是真失败。会用weight减少优先级（1-255之间）
    rise 1 #检测1次成功就算成功。但不修改优先级
}

vrrp_instance VI_1 {
    state MASTER #指定keepalived的角色，MASTER是主，BACKUP是备用
    interface ens33 #指定虚拟ip的网卡接口
    mcast_src_ip 172.20.10.1 #发送多播数据包时的源IP地址
    virtual_router_id 51 #路由器标识，MASTER和BACKUP必须是一致的
    priority 101 #定义优先级，数字越大，优先级越高，在同一个vrrp_instance下，MASTER的优先级必须大于BACKUP的优先级。这样MASTER故障恢复后，就可以将VIP资源再次抢回来 
    advert_int 1 #设定主与备之间同步检查的时间间隔，单位是秒
    authentication { #设置验证类型和密码。主从必须一样
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        172.20.10.3 #VRRP HA 虚拟地址 如果有多个VIP，继续换行填写
    }

    track_script { #执行监控的服务
        chk_mysql_port
    }
}
```
* #### `node2` 配置

```
! Configuration File for keepalived

global_defs {
    router_id MASTER-HA
}

vrrp_script chk_mysql_port {
    script "/opt/chk_mysql.sh"
    interval 2
    weight -5
    fall 2
    rise 1
}

vrrp_instance VI_1 {
    state BACKUP
    interface ens33
    mcast_src_ip 172.20.10.2
    virtual_router_id 51
    priority 99
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        172.20.10.3
    }

    track_script {
        chk_mysql_port
    }
}
```



```shell
vim /opt/chk_mysql.sh #切换脚本

#-----------
#!/bin/bash
counter=$(netstat -na|grep "LISTEN"|grep "3306"|wc -l)
if [ "${counter}" -eq 0 ]; then
    /etc/init.d/keepalived stop
fi
#-----------

chmod 755 /opt/chk_mysql.sh

#配置日志
vim /etc/sysconfig/keepalived   #修改
	KEEPALIVED_OPTIONS="-f /etc/keepalived/keepalived.conf  -D -S 0"  

vim  /etc/rsyslog.conf   #增加
	local0.*          /var/log/keepalived/keepalived.log 
	
mkdir /var/log/keepalived 
touch /var/log/keepalived/keepalived.log

systemctl restart rsyslog
systemctl restart keepalived
```



## 防火墙相关

如果不关闭防火墙，需要在两个节点之间开通如下访问关系：

* -A INPUT -s 10.0.0.0/24 -d 224.0.0.18 -j ACCEPT       #允许组播地址通信
*  -A INPUT -s 10.0.0.0/24 -p vrrp -j ACCEPT             #允许VRRP（虚拟路由器冗余协）通信
*  -A INPUT -m state --state NEW -m tcp -p tcp --dport 3306 -j ACCEPT    #开放mysql的3306端口