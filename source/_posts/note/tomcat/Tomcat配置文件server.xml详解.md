---
title: 详解Tomcat配置文件server.xml
date: 2026-06-15
tags:
  - tomcat
  - java
  - server.xml
  - web服务器
categories:
  - note
---

Tomcat 隶属于 Apache 基金会，是开源的轻量级 Web 应用服务器，使用非常广泛。server.xml 是 Tomcat 中最重要的配置文件，server.xml 的每一个元素都对应了 Tomcat 中的一个组件。

<!--more-->

## 整体结构

```xml
<Server>
    <Service>
        <Connector />
        <Connector />
        <Engine>
            <Host>
                <Context />
            </Host>
        </Engine>
    </Service>
</Server>
```

## 元素分类

### 顶层元素

- **`<Server>`** 是整个配置文件的根元素
- **`<Service>`** 代表一个 Engine 元素以及一组与之相连的 Connector 元素

### 连接器 `<Connector>`

`<Connector>` 代表了外部客户端发送请求到特定 Service 的接口；同时也是外部客户端从特定 Service 接收响应的接口。

```xml
<Connector port="8080" protocol="HTTP/1.1"
           connectionTimeout="20000"
           redirectPort="8443" />

<Connector port="8009" protocol="AJP/1.3" redirectPort="8443" />
```

### 容器

容器的功能是处理 Connector 接收进来的请求，并产生相应的响应。Engine、Host 和 Context 都是容器，是父子关系：Engine → Host → Context。

- **`<Engine>`** 处理 Service 中的所有请求
- **`<Host>`** 处理发向一个特定虚拟主机的所有请求
- **`<Context>`** 处理一个特定 Web 应用的所有请求

## 核心组件

### Server

```xml
<Server port="8005" shutdown="SHUTDOWN">
```

- port：接收远程关闭命令的端口
- shutdown：关闭 Tomcat 的命令字符串

### Service

```xml
<Service name="Catalina">
```

一个 Service 可以包含多个 Connector 和一个 Engine。

### Connector

```xml
<Connector port="8080"
           protocol="HTTP/1.1"
           connectionTimeout="20000"
           redirectPort="8443"
           maxThreads="200"
           minSpareThreads="10"
           acceptCount="100"
           enableLookups="false"
           compression="on"
           compressionMinSize="2048"
           noCompressionUserAgents="gozilla,traviata"
           compressableMimeType="text/html,text/xml,text/javascript,application/javascript" />
```

### Engine

```xml
<Engine name="Catalina" defaultHost="localhost">
```

### Host

```xml
<Host name="localhost" appBase="webapps"
      unpackWARs="true" autoDeploy="true">
```

- name：虚拟主机名
- appBase：应用基础目录
- unpackWARs：是否解压 WAR 包
- autoDeploy：是否自动部署

### Context

```xml
<Context path="/myapp" docBase="myapp" reloadable="true" />
```

- path：URL 路径
- docBase：应用文档路径
- reloadable：修改后是否自动重新加载

## 其他组件

### Listener

```xml
<Listener className="org.apache.catalina.startup.VersionLoggerListener" />
<Listener className="org.apache.catalina.core.AprLifecycleListener" SSLEngine="on" />
<Listener className="org.apache.catalina.core.JasperListener" />
```

### GlobalNamingResources 与 Realm

```xml
<GlobalNamingResources>
    <Resource name="UserDatabase" auth="Container"
              type="org.apache.catalina.UserDatabase"
              factory="org.apache.catalina.users.MemoryUserDatabaseFactory"
              pathname="conf/tomcat-users.xml" />
</GlobalNamingResources>

<Realm className="org.apache.catalina.realm.UserDatabaseRealm"
       resourceName="UserDatabase"/>
```

### Valve

```xml
<Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
       prefix="localhost_access_log." suffix=".txt"
       pattern="%h %l %u %t &quot;%r&quot; %s %b" />
```

### Cluster（集群配置）

```xml
<Cluster className="org.apache.catalina.ha.tcp.SimpleTcpCluster">
    <Manager className="org.apache.catalina.ha.session.DeltaManager"
             expireSessionsOnShutdown="false" />
    <Channel className="org.apache.catalina.tribes.group.GroupChannel">
        <Membership className="org.apache.catalina.tribes.membership.McastService"
                    address="228.0.0.4" port="45564" frequency="500" dropTime="3000"/>
        <Receiver className="org.apache.catalina.tribes.transport.nio.NioReceiver"
                  address="auto" port="4000" autoBind="100"
                  selectorTimeout="5000" maxThreads="6" />
        <Sender className="org.apache.catalina.tribes.transport.ReplicationTransmitter">
            <Transport className="org.apache.catalina.tribes.transport.nio.PooledParallelSender" />
        </Sender>
        <Interceptor className="org.apache.catalina.tribes.group.interceptors.TcpFailureDetector" />
        <Interceptor className="org.apache.catalina.tribes.group.interceptors.KeepingInterceptor" />
    </Channel>
    <Valve className="org.apache.catalina.ha.tcp.RequestDumperValve"/>
    <Valve className="org.apache.catalina.ha.session.JvmRouteBinderValve"/>
    <Deployer className="org.apache.catalina.ha.deploy.FarmWarDeployer"
              tempDir="/tmp/war-temp/" deployDir="/tmp/war-deploy/"
              watchDir="/tmp/war-watch/" watchEnabled="false" />
    <ClusterListener className="org.apache.catalina.ha.session.ClusterSessionListener" />
</Cluster>
```
