---
title: iptables工具
date: 2020-2-20
updated: 2020-2-21
categories:
  - note
abbrlink: f71faba5
---
    iptables -L -n #查看iptables已有策略
	iptables -A INPUT -p tcp -dport 80 -j ACCEPT 
	#打开80端口的权限（appche服务的默认端口）
	iptables -A INPUT -p tcp -dport 3306 -j ACCEPT 
	#打开80端口的权限（mysql服务的默认端口） 
	#此时已经打开了iptables的两个端口，但是这种更改是临时的，当iptables重启时，上述两条策略就会失效。所以需要用下边的命令将策略保存
	/etc/init.d/iptables save  
	#这条命令就是为了将更改的策略写进/etc/sysconfig/iptables保存起来
	iptables -A INPUT -s 192.168.0.3 -p tcp --dport 22 -j ACCEPT 
	#设定某一地址对端口的权限