---
title: tomcat目录结构
date: 2019-10-18
updated: 2019-10-19
categories:
  - note
abbrlink: 82b89847
---
tomcat文件目录

1、目录结构

进入tomcat安装目录下：

|-- bin

|   |-- bootstrap.jar	tomcat启动时所依赖的一个类，在启动tomcat时会发现Using CLASSPATH: 是加载的这个类

|   |-- catalina-tasks.xml	定义tomcat载入的库文件，类文件

|   |-- catalina.bat

|   |-- catalina.sh	                 tomcat单个实例在Linux平台上的启动脚本

|   |-- commons-daemon-native.tar.gz	           jsvc工具，可以使tomcat已守护进程方式运行，需单独编译安装

|   |-- commons-daemon.jar	           jsvc工具所依赖的java类

|   |-- configtest.bat

|   |-- configtest.sh	        tomcat检查配置文件语法是否正确的Linux平台脚本

|   |-- cpappend.bat

|   |-- daemon.sh	tomcat已守护进程方式运行时的，启动，停止脚本

|   |-- digest.bat

|   |-- digest.sh

|   |-- setclasspath.bat

|   |-- setclasspath.sh

|   |-- shutdown.bat

|   |-- shutdown.sh	tomcat服务在Linux平台下关闭脚本

|   |-- startup.bat

|   |-- startup.sh	         tomcat服务在Linux平台下启动脚本

|   |-- tomcat-juli.jar

|   |-- tomcat-native.tar.gz	 使tomcat可以使用apache的apr运行库，以增强tomcat的性能需单独编译安装

|   |-- tool-wrapper.bat

|   |-- tool-wrapper.sh

|   |-- version.bat

|   |-- version.sh	查看tomcat以及JVM的版本信息

|-- conf	顾名思义，配置文件目录

|   |-- catalina.policy	配置tomcat对文件系统中目录或文件的读、写执行等权限，及对一些内存，session等的管理权限

|   |-- catalina.properties	配置tomcat的classpath等

|   |-- context.xml	tomcat的默认context容器

|   |-- logging.properties	配置tomcat的日志输出方式

|   |-- server.xml	       tomcat的主配置文件

|   |-- tomcat-users.xml	       tomcat的角色(授权用户)配置文件

|   |-- web.xml	tomcat的应用程序的部署描述符文件

|-- lib

|-- logs	日志文件默认存放目录

|-- temp

|   |-- safeToDelete.tmp

|-- webapps	          tomcat默认存放应用程序的目录，好比apache的默认网页存放路径是/var/www/html一样

|   |-- docs	tomcat文档

|   |-- examples                     tomcat自带的一个独立的web应用程序例子

|   |-- host-manager              tomcat的主机管理应用程序

|	|   |-- META-INF	          整个应用程序的入口，用来描述jar文件的信息

|	|   |   |-- context.xml     当前应用程序的context容器配置，它会覆盖tomcat/conf/context.xml中的配置

|	|   |-- WEB-INF	 用于存放当前应用程序的私有资源

|	|   |   |-- classes	 用于存放当前应用程序所需要的class文件

|       |   |	|-- lib	         用于存放当前应用程序锁需要的jar文件

|	|   |   |-- web.xml	当前应用程序的部署描述符文件，定义应用程序所要加载的serverlet类，以及该程序是如何部署的

|   |-- manager                  tomcat的管理应用程序

|   |-- ROOT	             指tomcat的应用程序的根，如果应用程序部署在ROOT中，则可直接通过http://ip:port 访问到

|-- work	用于存放JSP应用程序在部署时编译后产生的class文件

1. /home/ap/tomcat/tomcat8080/webapps/TDP/WEB-INF/classes

这个目录是tomcat需要注意的配置目录之一。/home/ap/tomcat/是tomcat用户的家目录。tomcat8080/是8080端口tomcat的配置目录。在该目录下的webapps/下会有一个应用名字的目录，该tomcat的应用名字即为TDP。然后在TDP/WEB-INF/classes下，会有一个.properties文件。不同的应用名字可能不同，但是后缀一般相同，这个就是tomcat的配置文件。需要着重关注的是关于mysql以及redis的配置。其他的配置主要与软件本身性能有关。

/home/ap/tomcat/tomcat8889/bin

这个目录是tomcat的一些运行脚本以及jar包。

1. tomcat的默认端口是8080.当需要更改端口时，不能只更改一个8080.
   tomcat服务总共有3个端口。connector、shutdown、redirectPort。更改时，需要将三个端口一起更改。常见的更改方式为n、n+1、n+2。
   需要修改的文件在tomcat/conf/server.xml。
   内容分别为：
       <Connector port="8080" protocol="HTTP/1.1"
                connectionTimeout="20000"
                redirectPort="8443" />
       
       <Connector port="8009" protocol="AJP/1.3" redirectPort="8443" />
       <Server port="8005" shutdown="SHUTDOWN">
       #将其中的8080、8009、8005改为系统未占用的端口即可。
   其中的ajp也是TCP/IP的一种协议，叫做定向包协议。
