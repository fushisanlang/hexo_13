---
title: activeMQ安装及密码配置
date: 2017-11-6
updated: 2017-11-7
tags:
  - activeMQ
categories:
  - note
abbrlink: 8c648696
---

#### 1. 什么是activeMQ   
ActiveMQ是一种开源的，实现了JMS1.1规范的，面向消息(MOM)的中间件，为应用程序提供高效的、可扩展的、稳定的和安全的企业级消息通信。   

<!--more-->

#### 2. 部署   
	mkdir /activemq
	tar zxf apache-activemq-5.14.4-bin.tar.gz -C /activemq/
	cd /activemq/
	cd apache-activemq-5.14.4/
	cd bin/
	./activemq start   #此时服务已经开启，默认的端口为61616
	netstat -anp | grep 61616

#### 3. 密码配置   
在activemq服务的根目录下/conf/activemq.xml中有这样一个bean值：

	<!-- Allows us to use system properties as variables in this configuration file -->
	<bean class="org.springframework.beans.factory.config.PropertyPlaceholderConfigurer">
	<property name="locations">
	<value>file:${activemq.base}/conf/credentials.properties</value>
	</property> 
	</bean>

 

这个文件/conf/credentials.properties就是密码所在的位置，但是默认情况下是没有使用的，需要增加插件

	   <plugins>   
        <simpleAuthenticationPlugin>   
            <users>   
                <authenticationUser username="${activemq.username}" password="${activemq.password}" groups="users,admins"/>   
            </users>   
        </simpleAuthenticationPlugin>   
    </plugins>   
    
    vim jetty-realm.properties
        #此文件是activemq的链接密码
        admin： name, password
        
    vim credentials.properties
        #此文件是activemq的管理密码
        activemq.username=admin
        activemq.password=admin
