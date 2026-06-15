---
title: Kettle(Pentaho)实现web方式远程执行job或transformation
date: 2026-06-15
tags:
  - kettle
  - pentaho
  - etl
  - carte
categories:
  - note
---

Kettle 自带 Carte 功能可以开启 Web 服务器，实现通过浏览器远程触发 Job 或 Transformation 执行，省去登录服务器操作。

<!--more-->

## 准备工作

1. 安装 Java JDK 1.5 以上
2. 下载 Kettle 并解压到指定目录
3. 配置环境变量 `PENTAHO_JAVA_HOME`，指向 JDK 的 jre 目录

## 开启 Carte 服务器

```bash
cd kettle根目录
carte.bat 127.0.0.1 8081
```

成功后在浏览器打开 `http://127.0.0.1:8081`，用账号密码登录。

账号密码在 `pwd/8081.xml` 文件中，默认用户名密码都是 `cluster`：

```xml
<slaveserver>
  <name>slave1-8081</name>
  <hostname>localhost</hostname>
  <port>8081</port>
  <username>cluster</username>
  <password>cluster</password>
  <master>N</master>
</slaveserver>
```

## 配置 Kettle 文件

### 1. 配置 Slave Server

在 Kettle 中打开 Job 或 Transformation，左侧菜单选择 View → Slave Server，新建一个 Server：

- IP 和 Port 必须与 Carte 服务器一致
- 配置完成后点击 OK 并 Share

### 2. 配置 Run Options

打开 Job 或 Transformation，配置 Run Options，指定 Remote Slave Server。

配置完成后，刷新 `http://127.0.0.1:8081`，即可在 Web 界面看到对应的 Job，点击即可远程触发执行。
