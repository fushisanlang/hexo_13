---
title: glances 工具
date: 2016-12-2
updated: 2016-12-3
tags:
  - glances
categories:
  - note
abbrlink: fef299cd
---


#### 介绍

Glances是一个相对比较新的系统监控工具，用 Python 编写的，使用 psutil 库从系统获取信息。
你可以用它来监控 CPU、平均负载、内存、网络接口、磁盘 I/O，文件系统空间利用率、挂载的设备、所有活动进程以及消耗资源最多的进程。
Glances 有很多有趣的选项。它的主要特性之一是可以在配置文件中设置阀值（careful小心、warning警告、critical致命），然后它会用不同颜色显示信息以表明系统的瓶颈。

#### 安装

`yum install -y glances`

<!--more-->

#### glances 工作界面的说明

在命令行输入`glances`命令，打开glances工具。

```shell
VIRT    #虚拟内存大小 
RES     #进程占用的物理内存值 
%CPU    #该进程占用的 CPU 使用率 
%MEM    #该进程占用的物理内存和总内存的百分比 
PID     #进程 ID 号 
USER    #进程所有者的用户名 
TIME+   #该进程启动后占用的总的 CPU 时间 
NAME    #进程名称 
NI      #进程优先级 
S       #进程状态，其中 S 表示休眠，R 表示正在运行，Z 表示僵死状态。
IO_R 和 IO_W    #进程的读写 I/O 速率 
```

#### 常用快捷键

```shell
m    #按内存占用排序进程 
p    #按进程名称排序进程 
c    #按 CPU 占用率排序进程 
i    #按 I/O 频率排序进程 
a    #自动排序进程 
d    #显示/隐藏磁盘 I/O 统计信息 
f    #显示/隐藏文件系统统计信息 
s    #显示/隐藏传感器统计信息 
y    #显示/隐藏硬盘温度统计信息 
l    #显示/隐藏日志 
n    #显示/隐藏网络统计信息 
x    #删除警告和严重日志 
h    #显示/隐藏帮助界面 
q    #退出 
w    #删除警告记录
```

#### 命令行参数

```shell
-s    #设置 glances 运行模式为服务器 
-b    #显示网络连接速度 Byte/ 秒 
-d    #关闭磁盘 I/O 模块 
-e    #显示传感器温度 
-m    #关闭挂载的磁盘模块 
-n    #关闭网络模块 
-h    #显示帮助信息 
-v    #显示版本信息
-B @IP|host     #绑定服务器端 IP 地址或者主机名称 
-c @IP|host     #连接 glances 服务器端 
-C file         #设置配置文件默认是 /etc/glances/glances.conf 
-f file         #设置输出文件（格式是 HTML 或者 CSV） 
-p PORT         #设置运行端口默认是 61209 
-P password     #设置客户端 / 服务器密码 
-t sec          #设置屏幕刷新的时间间隔，单位为秒，默认值为 2 秒，数值许可范围为1~32767 
```
