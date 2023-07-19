---
title: 编译安装erlang并配置rabbitmq集群
date: 2020-2-2
updated: 2020-2-3
tags:
  - rabbitmq
  - erlang
categories:
  - note
abbrlink: e57a84c1
---


* ### 环境介绍

序号|ip|主机名|系统信息
-|-|-|-
1|172.20.10.1|node10-1|centos6.7 x86_64
2|172.20.10.2|node10-2|centos6.7 x86_64
2|172.20.10.3|node10-3|centos6.7 x86_64

* ### 安装基础环境

```shell
yum groupinstall "Development Tools" -y
yum install epel-release
yum install gcc c++ zip unzip man vim telnet wget nethogs htop glances dstat traceroute lrzsz goaccess ntpdate dos2unix openssl-devel xinetd lvm2
```

* ### 配置系统最大文件数
```shell
vim /etc/security/limits.conf
	*    soft nofile 655360
	*    hard nofile 655360
```


* ### 下载安装erlang和rabbitmq
```shell
mkdir -p /soft
cd /soft
wget http://erlang.org/download/otp_src_22.1.tar.gz https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.8.1/rabbitmq-server-generic-unix-3.8.1.tar.xz
tar xf otp_src_22.1.tar.gz 
cd otp_src_22.1
./otp_build autoconf
yum install ncurses-devel
./configure --without-javac
make
make install
tar xf rabbitmq-server-generic-unix-3.8.1.tar.xz
mv rabbitmq_server-3.8.1/ /usr/local/rabbitmq
```

* ### 配置环境变量
```shell
echo 'export ERLANG_HOME=/usr/local/lib/erlang' >> /etc/profile
echo 'export RABBITMQ_HOME=/usr/local/rabbitmq' >> /etc/profile
echo 'export PATH=$PATH:$ERLANG_HOME/bin:$RABBITMQ_HOME/sbin' >> /etc/profile
source /etc/profile
```

* ### 开启web
```shell
rabbitmq-server -detached
rabbitmqctl start_app
rabbitmq-plugins enable rabbitmq_management
```

* ### 配置防火墙
```shell
/sbin/iptables -I INPUT -p tcp --dport 4369 -j ACCEPT
/sbin/iptables -I INPUT -p tcp --dport 5672 -j ACCEPT
/sbin/iptables -I INPUT -p tcp --dport 15672 -j ACCEPT
/sbin/iptables -I INPUT -p tcp --dport 25672 -j ACCEPT
/etc/rc.d/init.d/iptables save
/etc/init.d/iptables restart
```

* ### 配置主机名和hosts
```shell
#HOSTNAME每台主机不同。每个节点的hosts中都要有集群所有主机的解析
sed '/HOS/d' /etc/sysconfig/network
echo 'HOSTNAME={{HOSTNAME}}' >> /etc/sysconfig/network
hostname {{HOSTNAME}}
echo {{IP}} {{HOSTNAME}} >> /etc/hosts #要在所有主机中，加入所有主机的解析
```

* ### 同步cookie
```shell
vim /root/.erlang.cookie #将内容改为主节点文件内容
```

* ### 创建集群

* 主节点
```shell
rabbitmqctl start_app
```
* 其他节点
```shell
rabbitmqctl stop_app
rabbitmq-server join_cluster rabbit@node10-1 #此处填写主节点的hostname信息
rabbitmqctl start_app
```

* ### 配置用户
* 主节点
```shell
rabbitmqctl delete_user guest
rabbitmqctl add_user zy zy
rabbitmqctl set_user_tags zy administrator
```