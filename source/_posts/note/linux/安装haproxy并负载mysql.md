---
title: 安装haproxy并负载mysql
date: 2019-3-7
updated: 2019-3-8
tags:
  - haproxy
  - mysql
categories:
  - note
abbrlink: 306013b0
---
```shell
    cd /soft  #将软件包放在此目录
    tar xzvf haproxy-1.7.5.tar.gz
    cd /soft/haproxy-1.7.5/
    make TARGET=linux2628 PREFIX=/usr/local/haproxy
    make install PREFIX=/usr/local/haproxy  #编译安装
    groupadd haproxy
    useradd -g haproxy haproxy -s /sbin/nologin
    mkdir -p /usr/local/haproxy/etc
    cd /usr/local/haproxy/etc
    chown -R haproxy:haproxy /usr/local/haproxy


    echo -e 'SYSLOGD_OPTIONS="-c 2 -r -m 0"' >> /etc/sysconfig/rsyslog
    #使用syslogs options。
    #在该文件中有提示If you want to use them, switch to compatibility mode 2 by "-c 2"
    
    
    sed -i '13,14s/^#//g' /etc/rsyslog.conf
    #去掉两行配置文件的注释，因为要使用UDP服务管理日志，所以需要打开rsyslog的UDP端口
    
    echo -e 'local3.*                                                /var/log/haproxy.log' >> /etc/rsyslog.conf 
    #一共有8个日志级别，紧急状态、戒备、重要、错误、警告、通知、正常消息、调试
    #local3是指错误级别及错误级别以上的重要、戒备、紧急状态级别
    #通过上述配置，将3级日志放入/var/log/haproxy.log下  

    vim  /usr/local/haproxy/etc/haproxy.cfg
        #配置haproxy的配置文件，具体配置方法见文尾附件一。

    mkdir -pv /var/lib/haproxy/
    chmod +x /etc/init.d/haproxy
    #如果显示没有该文件，可以粘贴文尾附件二。
    service haproxy restart  
    chkconfig haproxy on
    service rsyslog restart
    chkconfig rsyslog on
```    
此时可以通过web访问 `IP:8080/haproxy/stats` 来查看当前 `haproxy` 状态。
此时后端数据库的状态应该都是错误的，因为 `haproxy` 无法访问后端数据库，无法对其进行检查。
    
所以需要在后段数据库服务器进行如下操作：
```
    yum -y install xinetd
    /etc/init.d/xinted start
	chkconfig xinetd on
	mysql -hlocalhost -p
	    > GRANT PROCESS ON *.* TO 'clustercheckuser'@'localhost' IDENTIFIED BY 'clustercheckpassword!';
    
	clustercheck  #通过此命令检测，如果回显为以下信息，表示可用。将所有后端服务器进行此操作后，web界面显示的就是后端服务器真实的状态。
        HTTP/1.1 200 OK
        Content-Type: text/plain
        Connection: close
        Content-Length: 40
    
        Percona XtraDB Cluster Node is synced.
```
    
    
