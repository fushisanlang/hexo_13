---
title: gocron - 定时任务管理系统
date: 2018-11-13
updated: 2018-11-14
tags:
  - gocron
categories:
  - note
abbrlink: 2356ccf6
---

### 项目简介

使用Go语言开发的定时任务集中调度和管理系统, 用于替代Linux-crontab [github地址](https://github.com/ouqiang/gocron)

### 功能特性

- Web界面管理定时任务
- crontab时间表达式, 精确到秒
- 任务执行失败可重试
- 任务执行超时, 强制结束
- 任务依赖配置, A任务完成后再执行B任务
- 账户权限控制
- 任务类型
  - shell任务   
    >访问指定的URL地址, 由调度器直接执行, 不依赖任务节点
  - HTTP任务   
    >在任务节点上执行shell命令, 支持任务同时在多个节点上运行

- 查看任务执行结果日志
- 任务执行结果通知, 支持邮件、Slack

*具体功能实现请访问项目地址。*

<!--more-->

### 安装试用

#### 环境介绍

阿里云ecs：系统centos 6.7、关闭selinux、关闭iptables、安全组打开5920、5921端口

mysql：5.1.73

#### 安装

    yum install golang -y
    useradd gocron
    mkdir -p /soft/gocron
    mkdir -p /usr/local/gocron
    cd /soft/gocron
    wget 'https://github.com/ouqiang/gocron/releases/download/v1.4/gocron-v1.4-linux-amd64.tar.gz'  #调度器
    wget 'https://github.com/ouqiang/gocron/releases/download/v1.4/gocron-node-v1.4-linux-amd64.tar.gz'  #任务节点
    tar zxf gocron-v1.4-linux-amd64.tar.gz -C /usr/local/gocron
    tar zxf gocron-node-v1.4-linux-amd64.tar.gz -C /usr/local/gocron
    
    su - gocron
    mkdir ~/workspace
    echo 'export GOPATH="$HOME/workspace"' >> ~/.bashrc
    source ~/.bashrc

#### 启动

    cd /usr/local/gocron/gocron_linux_amd64
    ./gocron web #启动调度器
    cd /usr/local/gocron/gocron-node_linux_amd64
    ./gocron-node #启动任务节点
    #不要使用root用户启动。并且启动用户即为任务的执行用户。所以要注意用户权限问题。

#### 配置

*调度器需要MySQL数据库权限，为了安全，对其新建数据库，并创建新用户*
    
    mysql -h127.0.0.1 -uroot -p
    > create DATABASE gocron;
    > CREATE USER 'user'@'127.0.0.1' IDENTIFIED BY 'passwd';
    > GRANT SELECT, INSERT, UPDATE, REFERENCES, DELETE, CREATE, DROP, ALTER, INDEX, TRIGGER, CREATE VIEW, SHOW VIEW, EXECUTE, ALTER ROUTINE, CREATE ROUTINE, CREATE TEMPORARY TABLES, LOCK TABLES, EVENT ON `gocron`.* TO 'user'@'127.0.0.1'; 


通过浏览器访问IP:5920,并按照提示进行配置。

#### 

先通过 **任务节点->添加节点** 菜单添加任务节点。

然后通过 **任务 -> 添加任务** 菜单进行任务添加。

添加过程中，可以添加shell任务，类似于linux-crontab的任务计划。也可以添加http的get或post任务。
