---
title: 网线制作+xen相关+nfs共享
date: 2016-10-9
updated: 2016-10-10
categories:
  - note
tags:
  - nfs
  - xen
  - 网线
abbrlink: 204b2a80
---
## **网线制作**   
网线有两种排线标准：   

* 568B：白橙、橙、白绿、蓝、白蓝、绿、白棕、棕色
* 568A：白绿、绿、白橙、蓝、白蓝、橙、白棕、棕色

两端均使用568B顺序的网线属于正常连接，常用于计算机与集线器之间的链接   
两端分别采用不同顺序的的网线属于交叉连接，常用与电脑与电脑，网卡与网卡之间的链接

## **xenserver6.5**   

Citrix Xenserver，思杰基于Linux的虚拟化服务器。Citrix XenServer是一种全面而易于管理的服务器虚拟化平台，基于强大的 Xen Hypervisor 程序之上。Xen技术被广泛看作是业界最快速、最安全的虚拟化软件。XenServer 是为了高效地管理 Windows(R) 和 Linux(R)虚拟服务器而设计的，可提供经济高效的服务器整合和业务连续性。   

1. xenserver6.5的安装   
本次实验是在windows下的vm上安装xenserver6.5。具体方法与安装一个Linux虚拟机相似，在选择镜像时选择xenserver6.5的安装镜像，并且选择2.6.X 64位的Linux内核即可。   
通过引导提示即可完成安装。

2. xencenter6.5的安装   
xencenter是一个exe文件，在windows下选择合适的目录安装即可。

3. 通过xencenter管理xenserver   
在windows的xencenter安装目录下找到xencenter.exe,双击运行。   
在界面中选择添加，通过输入IP、用户名以及密码即可通过xencenter管理xenserver。

4. 在xenserver上建立虚拟机      
因为xenserver本身就是通过vm建立的虚拟机，所以需要在vm对于xenserver的处理器设置中，允许xenserver的虚拟化。     
在xencenter中，选择需要建立虚拟机的xenserver服务器。选择新建vm。按照步骤进行即可。   
需要注意的是，通过xencenter创建虚拟机时，不能直接使用存在于硬盘中的iso镜像文件。而是需要icsci或者nfs共享iso镜像。   
所以在试验中，通过另一台centos6.7的机器，使用nfs共享了一个iso镜像。*集体操作方法在后面*   
通过引导即可创建一个可用的虚机。通过开启虚机完成系统安装即可。   

##  **简易nfs服务器**

本处目的在于搭建一个自己使用的或小范围使用的nfs服务器，而非放在网络上的服务器，所以为了操作简便，直接关闭了火墙。   
一个Linux系统：
```
	yum install nfs-utils -y
	/etc/init.d/iptables stop
	setenforce 0
	/etc/init.d/nfs start
	vim /etc/exports
		/share     #将要共享的目录
		192.168.26.130(ro)	  #允许共享的IP以及共享方式
	mkdir /share
	cp ***.iso /share    #已经准备好的镜像文件
	exportfs -rv    #刷新服务
```
通过上述操作，即可通过nfs将iso共享给192.168.26.130。  

可以通过在130上输入：
```
	showmount -e 192.168.26.129
```
查看共享是否成功。可以通过：
```
	mount 192.168.26.129：/share  /mnt 
```
直接使用共享的内容。

 
