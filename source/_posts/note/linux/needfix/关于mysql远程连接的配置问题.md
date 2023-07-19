---
title: 关于mysql远程连接的配置问题
date: 2018-9-23
updated: 2018-9-24
categories:
  - note
tags:
  - mysql
abbrlink: 920ae663
---
## **mysql授权远程连接**

		GRANT ALL PRIVILEGES ON *.* TO 'root'@'%'IDENTIFIED BY 'qaz000123' WITH GRANT OPTION; #授权给root账户通过qaz000123密码远程链接数据库的权限
	FLUSH PRIVILEGES; #刷新用户表信息，使之前的授权生效。否则需要重新启动mysql服务

##  **navicat远程连接mysql的2003错误**

原因1 ： mysql未开启服务   
原因2 ： mysql的用户名或密码错误   
原因3 ： mysql服务或者navicat未指定端口。虽然默认的mysql的端口为3306，但是链接时不指定端口也会造成错误   
原因4 ： mysql端防火墙问题   

##  **关于mysql服务器的防火墙配置**
		
		iptables -L -n #查看iptables已有策略
	iptables -A INPUT -p tcp -dport 80 -j ACCEPT #打开80端口的权限（appche服务的默认端口）
	iptables -A INPUT -p tcp -dport 3306 -j ACCEPT #打开80端口的权限（mysql服务的默认端口） 
	#此时已经打开了iptables的两个端口，但是这种更改是临时的，当iptables重启时，上述两条策略就会失效。所以需要用下边的命令将策略保存
	/etc/init.d/iptables save  #这条命令就是为了将更改的策略写进/etc/sysconfig/iptables保存起来
	iptables -A INPUT -s 192.168.0.3 -p tcp --dport 22 -j ACCEPT #设定某一地址对端口的权限
