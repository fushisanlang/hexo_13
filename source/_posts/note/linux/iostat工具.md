---
title: iostat命令详解
date: 2020-7-21
updated: 2020-7-22
tags:
  - iostat
categories:
  - note
abbrlink: 59a882d9
---


iostat用于输出cpu和磁盘I/O的统计信息。   
**命令格式**

	iostat --help
	Usage: iostat [ options ] [ <interval> [ <count> ] ]
	Options are:
	[ -c ] [ -d ] [ -N ] [ -n ] [ -h ] [ -k | -m ] [ -t ] [ -V ] [ -x ] [ -y ] [ -z ]
	[ -j { ID | LABEL | PATH | UUID | ... } [ <device> [...] | ALL ] ]
	[ <device> [...] | ALL ] [ -p [ <device> [,...] | ALL ] ]

**输出示例**

<!--more-->
	# iostat 
	Linux 2.6.32-573.el6.x86_64 (localhost.localdomain) 	03/28/2017 	_x86_64_	(1 CPU)
	
	avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           1.12    0.00    2.51    3.26    0.00   93.10

	Device:            tps   Blk_read/s   Blk_wrtn/s   Blk_read   Blk_wrtn
	sda              14.35       839.05       102.48     647160      79044

各个输出项目的含义如下:

**avg-cpu段:**   
%user: 在用户级别运行所使用的CPU的百分比   
%nice: nice操作所使用的CPU的百分比   
%sys: 在系统级别(kernel)运行所使用CPU的百分比   
%iowait: CPU等待硬件I/O时,所占用CPU百分比   
%idle: CPU空闲时间的百分比   
**Device段:**   
tps: 每秒钟发送到的I/O请求数   
Blk_read /s: 每秒读取的block数   
Blk_wrtn/s: 每秒写入的block数   
Blk_read:   读入的block总数   
Blk_wrtn:  写入的block总数

**参数说明**   
-c 仅显示CPU统计信息.与-d选项互斥   
 -d 仅显示磁盘统计信息.与-c选项互斥   
 -k 以K为单位显示每秒的磁盘请求数,默认单位块   
 -p 与-x选项互斥,用于显示块设备及系统分区的统计信息,如:   `iostat -p hda`   或`iostat -p ALL`   
 -t    在输出数据时,打印搜集数据的时间   
 -V    打印版本号和帮助信息   
 -x    输出扩展信息   

**控制输出**

	iostat                     #显示一条统计记录,包括所有的CPU和设备
	iostat -d 2                #每隔2秒,显示一次设备统计信息
	iostat -d 2 6              #每隔2秒,显示一次设备统计信息.总共输出6次
	iostat -x hda hdb 2 6      #每隔2秒显示一次hda,hdb两个设备的扩展统计信息,共输出6次
	iostat -p sda 2 6          #每隔2秒显示一次sda及上面所有分区的统计信息,共输出6次
