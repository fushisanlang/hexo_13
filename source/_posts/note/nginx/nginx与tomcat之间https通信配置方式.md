---
title: nginx与tomcat之间https通信配置方式
date: 2018-1-17
updated: 2018-1-18
tags:
  - nginx
  - tomcat
  - https
categories:
  - note
abbrlink: 77eff4f
---

### nginx与tomcat之间https通信配置方式

```
 <Engine name="Catalina" defaultHost="localhost" jvmRoute = "jvm-jspt1">
    <Valve className="org.apache.catalina.valves.RemoteIpValve"  
           remoteIpHeader="X-Forwarded-For"  
           protocolHeader="X-Forwarded-Proto"  
           protocolHeaderHttpsValue="https"/>
需要注意;
           remoteIpHeader="X-Forwarded-For"  
           protocolHeader="X-Forwarded-Proto" 
要在proxy文件中定义
```
