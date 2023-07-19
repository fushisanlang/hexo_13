---
title: redis集群
date: 2017-10-25
updated: 2017-10-26
tags:
  - redis
categories:
  - note
abbrlink: b153a32a
---

## 环境说明

**node1 centos6.7 192.168.96.1 关闭防火墙和selinux master**   
**node2 centos6.7 192.168.96.2 关闭防火墙和selinux slave**   
**node3 centos6.7 192.168.96.3 关闭防火墙和selinux slave**   

<!--more-->
## 软件准备

**redis-3.2.0.tar.gz**

## 软件安装
**node1 2 3**

	tar zxf redis-3.2.8.tar.gz
	cd redis-3.2.8
	yum install gcc -y ###源码编译安装需要C语言编译器，所以需要安装gcc
	make
	make install
	./utils/install_server.sh   #自动配置 包括端口配置文件等等
	
	
## 服务配置

经过上述操作，在三台主机上安装了redis的服务。但是由于redis本身的安全性配置，默认情况下是只允许通过本机连接的。

通过`telnet 127.0.0.1 6379`可以发现，redis的服务是可以使用的。但是`telnet 192.168.96.1 6379`会发现拒绝访问。   
*并不推荐使用telnet，以为此工具并不安全，不建议开启。测试时可以直接通过redis-cli -ip的方式连接测试*      
这是因为在redis中有一个bind参数，通过此参数限制了可以连接的IP。   
在配置文件中，通过添加`bind ip`来添加允许连接的地址。    
需要注意的是，在3.2版本以前，不通过bind指定任何地址代表允许任意地址链接。   
但是在3.2版本开始，redis新增了保护机制，不指定地址的话，会默认拒绝所有链接，如果想要通过不指定地址的方式进行配置，需要将`protected-mode`参数关闭，即由yes改为no，以此关闭保护模式。

**上述操作是必不可少的，在集群搭建中，至少需要三个节点之间可以互相访问端口。**   
**如果三个节点不能相互访问，将无法得知master的状态，也无法形成集群。**   
**上述配置成功的测试方法有两种。**   
**一种是通过`telnet IP port`的方式，另一种则是直接通过`redis-cli -h IP`的方式。**   
**因为telnet的不安全性，不建议开始telnet，所以最好可以使用后一种方法。**

通过上述配置，使三个节点可以互相连接。   
**node2 3**
    
    echo 'slaveof 192.168.96.1 6379' >> /etc/redis/6379.conf
    /etc/init.d/redis_6379 restart
    
通过此方式，将两个slave端和master端绑定。   
此时，可以通过

    redis-cli -h IP info replication  
    #IP为想要查询状态的redis地址，如192.168.96.1
    
来查询集群状态。   
如果是master，会显示其余加入集群的slave的信息。   
如果是slave，会显示master的连接时间或下线时间。

**通过此方法搭建的集群为主从集群，只有master对数据库的权限是读写，slave的权限为只读。**


## redis-sentinel服务

在日常使用中，由于特殊原因，有时master节点会停止服务。   
如果是单点使用，则此时所有链接redis的服务都会受到影响。   
所以我们搭建了集群来确保服务的稳定性。   
本次试验中，选择了三机（一主两从）热备的方式搭建了集群。这样可以大幅度提高系统的稳定性。   
但是此时，只是有三个数据库在同步的记录数据，当master节点停止服务后，虽然数据还在slave节点上有备份，但是因为slave节点时只读的，无法执行写入操作，所以还是会对业务产生影响。   
所以此时，可以通过redis自带的redis-sentinel服务自动监视集群，当master无法提供服务时，通过redis-sentinel服务，将某一slave节点升级为master节点。   

**但是此种方式有局限性，只能通过检查在master节点出现问题时，将某一个slave节点提升为master节点，却无法将坏点的节点重启并重新加入集群。**

## 通过redis-sentinel服务实现主从切换
**node1 2 3**


    vim /etc/redis/sentinel.conf
        port 26379 
        daemonize yes
        protected-mode no
        logfile "/home/redis/logs/sentinel.log" 
        sentinel announce-ip 192.168.0.201                       
        sentinel monitor mymaster 192.168.0.201 6379 2 
        sentinel down-after-milliseconds mymaster 15000 
        sentinel failover-timeout mymaster 900000
        sentinel parallel-syncs mymaster 1
    
    redis-sentinel  /etc/redis/sentinel.conf
    
因为在安装redis的同时，已经安装了redis-sentinel。我们只需要自己手动的去创建或修改配置文件即可。     

**配置文件含义：**

port 26379 ： 服务端口    

daemonize yes ： 是否开启守护进程，yes为开启。   

protected-mode no ： 同样的保护开关。此条与6379.conf的配置文件并不相同。   
6379.conf中，保护模式是用来保护他人对数据库的链接，如果开启，则非指定的地址无法连接数据库。   
此文件中的保护开关则不然。通过关闭此开关，才能将slave节点提升为master节点。   
如果开启此保护，则集群会一直停留在等待master重连的状态，无法实现主从切换。

logfile "/home/redis/logs/sentinel.log" ： 定义日志文件

sentinel announce-ip 192.168.96.1 ： 定义master节点

sentinel monitor mymaster 192.168.96.1 6379 2 ： 将master节点命名为mymaster。   
在集群工作是，会不同的检测master，即192.168.96.1 6379。   
当有两个slave投票认为master异常，将会产生一个新的master。

sentinel down-after-milliseconds mymaster 15000 ： 异常时间判定 15000ms   
即当超过15000ms无法连接master，则改节点会认为master异常。

sentinel failover-timeout mymaster 900000 ： 选举超时时间 900000ms   
即当判定master失效后，如果超过设定时间为选出新的master，则选举失败。   
试验中未出现超时，无法确定超时后会产生的后果。

sentinel parallel-syncs mymaster 1 ： 选举后同步服务器个数   
即在新的选举结束后，最多有多少服务器对新的master进行同步。   
个数越小则整个集群同步完成时间越慢，但是对master来说，压力也会越小。  

`redis-sentinel  /etc/redis/sentinel.conf`命令则是代表通过/etc/redis/sentinel.conf文件启动redis-sentinel服务。   
redis-sentinel服务还有另外一种启动方法：
    redis-server /etc/redis/sentinel.conf --sentinel
    
通过上述配置，当master节点出现故障时，集群会重新选举一个slaver成为新的master节点，以保证服务。   
但是就如同上文所说，此种方式组成的集群只有健康检查，无法将故障节点重启并重新加入集群。   
**还有另外需要注意的是，此种方法选举出新的master之后，原master手动加入集群后，并不会重新成为master，而是会作为slave存在。这就使得，如果不同节点的资源配置相差较大，那么可能会浪费资源。**   
**其次，选举过程应该是通过实时修改配置文件进行的。经过验证，在slave节点升级为master节点后。6379.conf配置文件中关于slave的描述消失，其他slave的6379.conf中的slaveof的对象也被修改成了新的master。**   
**而所有的sentinel.conf文件中，也是将master的地址改为新的节点。**
