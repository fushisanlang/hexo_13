---
title: 更改单一tomcat用户的java环境
date: 2019-1-16
updated: 2019-1-17
categories:
  - note
tags:
  - 环境变量
abbrlink: 4064e97b
---
## **更改单一tomcat用户的java环境**

*  操作历史
```
		netstat -tlnup | grep 8080
		ps -lef  | grep 10652
		su - tomcat
		env
		cd /opt/tomcat
		cd /usr/java/
		ll lib/dt.jar 
		ll lib/tools.jar
		cd
		vim .bash_profile
		source .bash_profile 
		env
		cd /opt/tomcat/bin
		sh shutdown.sh
		sh startup.sh
		tail -f logs/catalina.out 
		netstat -tlnup | grep 8080
```
* 操作思路

因为此服务器上，tomcat上只有一个服务，所以可以通过更改环境变量更改java环境。如果运行不停地tomcat服务，统一的更改java环境可能会造成其他的服务出现问题。具体更改方法在以后学习。   
更改时，通过端口查看服务，通过pid查看服务目录。   
在进入tomcat后，先确认要更改的java环境目录是否存在，查询到的tomcat目录是否正确。   
检查无误后，回到家目录，更改环境变量配置文件，刷新配置。   
检查环境变量是否更改成功。   
然后回到tomcat服务目录，重启服务。   
然后查看tomcat的日志，确认日志无误（可能出现报错，但是启动正常即可）后查看端口。   
端口开启即说明修改成功。   