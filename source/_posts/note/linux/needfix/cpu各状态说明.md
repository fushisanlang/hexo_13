---
title: cpu各状态说明
date: 2018-2-15
updated: 2018-2-16
categories:
  - note
abbrlink: 8bab4762
---
 CPU运行状态 解释
user 进程执行用户态代码耗费的CPU时间。
nice 在优先级高的用户级别执行时CPU占用率的百分比。
system 内核执行系统调用所使用的CPU时间。
idle CPU空闲并且系统没有未完成的磁盘I / O请求的时间百分比。
iowait CPU等待I/O输入输出的时间
irq CPU用于维护硬件中断所花费的时间百分比。
softirq CPU用于服务软件中断所花费的时间百分比。
steal 在虚拟化环境中运行的其他操作系统所花费的时间
guest CPU用于运行虚拟处理器的时间百分比。
dpc 服务延迟过程调用所花费的时间
interrupt 服务硬件中断所花费的时间 