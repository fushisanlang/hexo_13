---
title: lsof命令详解
date: 2019-7-15
updated: 2019-7-16
tags:
  - lsof
categories:
  - note
abbrlink: 94aba208
---

##  **lsof命令详解**

lsof(list open files)是一个列出当前系统打开文件的工具。在linux环境下，任何事物都以文件的形式存在，通过文件不仅仅可以访问常规数据，还可以访问网络连接和硬件。所以如传输控制协议 (TCP) 和用户数据报协议 (UDP) 套接字等，系统在后台都为该应用程序分配了一个文件描述符，无论这个文件的本质如何，该文件描述符为应用程序与基础操作系统之间的交互提供了通用接口。因为应用程序打开文件的描述符列表提供了大量关于这个应用程序本身的信息

<!--more-->
**输出显示**   
*因为该命令输出太长，所以通过head过滤了一部份*   

	lsof | head
	COMMAND    PID      USER   FD      TYPE             DEVICE SIZE/OFF       NODE NAME
	init         1      root  cwd       DIR                8,2     4096          2 /
	init         1      root  rtd       DIR                8,2     4096          2 /
	init         1      root  txt       REG                8,2   150352         54 /sbin/init
	init         1      root  mem       REG                8,2    65928     917741 /lib64/libnss_files-2.12.so
	init         1      root  mem       REG                8,2  1926480     931857 /lib64/libc-2.12.so
	init         1      root  mem       REG                8,2    93320     931885 /lib64/libgcc_s-4.4.7-20120601.so.1
	init         1      root  mem       REG                8,2    47112     931863 /lib64/librt-2.12.so
	init         1      root  mem       REG                8,2   145896     931859 /lib64/libpthread-2.12.so
	init         1      root  mem       REG                8,2   268232     931872 /lib64/libdbus-1.so.3.4.0

每行显示一个打开的文件，若不指定条件默认将显示所有进程打开的所有文件   
lsof输出各列信息的意义如下：   
COMMAND：进程的名称 PID：进程标识符   
USER：进程所有者   
FD：文件描述符，应用程序通过文件描述符识别该文件。如cwd、txt等 TYPE：文件类型，如DIR、REG等   
DEVICE：指定磁盘的名称   
SIZE：文件的大小   
NODE：索引节点（文件在磁盘上的标识）   
NAME：打开文件的确切名称   
FD 列中的文件描述符cwd 值表示应用程序的当前工作目录，这是该应用程序启动的目录，除非它本身对这个目录进行更改,txt 类型的文件是程序代码，如应用程序二进制文件本身或共享库，如上列表中显示的 /sbin/init 程序。   
其次数值表示应用程序的文件描述符，这是打开该文件时返回的一个整数。如上的最后一行文件/dev/initctl，其文件描述符为 10。u 表示该文件被打开并处于读取/写入模式，而不是只读 ® 或只写 (w) 模式。同时还有大写 的W 表示该应用程序具有对整个文件的写锁。该文件描述符用于确保每次只能打开一个应用程序实例。初始打开每个应用程序时，都具有三个文件描述符，从 0 到 2，分别表示标准输入、输出和错误流。所以大多数应用程序所打开的文件的 FD 都是从 3 开始。   
与 FD 列相比，Type 列则比较直观。文件和目录分别称为 REG 和 DIR。而CHR 和 BLK，分别表示字符和块设备；或者 UNIX、FIFO 和 IPv4，分别表示 UNIX 域套接字、先进先出 (FIFO) 队列和网际协议 (IP) 套接字

**参数详解**   
lsof语法格式是：   

	lsof ［options］ filename

	lsof a.txt #显示开启文件a.txt的进程
	lsof -c p #显示p进程现在打开的文件
	lsof -c -p x #列出进程号为x的进程所打开的文件
	lsof -g gid 显示归属gid的进程情况
	lsof +d /usr/local/ #显示目录下被进程开启的文件
	lsof +D /usr/local/ #同上，但是会搜索目录下的目录，时间较长
	lsof -d n #显示使用fd为n的进程
	lsof -i #用以显示符合条件的进程情况
	lsof -i[46] [protocol][@hostname|hostaddr][:service|port]
	  46 --> IPv4 or IPv6
	  protocol --> TCP or UDP
	  hostname --> Internet host name
	  hostaddr --> IPv4地址
	  service --> /etc/service中的 service name (可以不止一个)
	  port --> 端口号 (可以不止一个)

**常用命令**

	lsof `which httpd` #那个进程在使用apache的可执行文件
	lsof /etc/passwd #那个进程在占用/etc/passwd
	lsof /dev/hda1 #那个进程在占用hda1
	lsof /dev/cdrom #那个进程在占用光驱
	lsof -c sendmail #查看sendmail进程的文件使用情况
	lsof -c hhh -u ^aaa #显示出那些文件被以hhh打头的进程打开，但是并不属于用户aaa
	lsof -p 30297 #显示那些文件被pid为30297的进程打开
	lsof -D /tmp 显示所有在/tmp文件夹中打开的instance和文件的进程。但是symbol文件并不在列	
	lsof -u1000 #查看uid是100的用户的进程的文件使用情况
	lsof -ubbb #查看用户bbb的进程的文件使用情况
	lsof -u^bbb #查看不是用户bbb的进程的文件使用情况(^是取反的意思)
	lsof -i #显示所有打开的端口
	lsof -i:80 #显示所有打开80端口的进程
	lsof -i -U #显示所有打开的端口和UNIX domain文件
	lsof -i UDP@[url]www.akadia.com:123 #显示那些进程打开了到www.akadia.com的UDP的123(ntp)端口的链接
	lsof -i tcp@ohaha.ks.edu.tw:ftp -r #不断查看目前ftp连接的情况(-r，lsof会永远不断的执行，直到收到中断信号,+r，lsof会一直执行，直到没有档案被显示,缺省是15s刷新)
	lsof -i tcp@ohaha.ks.edu.tw:ftp -n #lsof -n 不将IP转换为hostname，缺省是不加上-n参数
