---
title: rhce模拟题
date: 2016-6-22
updated: 2016-6-23
tags:
  - rhce
  - exam
  - need fix
categories:
  - note
abbrlink: f3fcd0e8
---



#############
# RHCE 考试 #
#############

此次考试汇总你将使用多个操作系统,一台是您面前的物理机桌面系统,其
他系统时运行在桌面系统上的已经预装好了的虚拟机。除非特别指出,所有
考试要求都是在虚拟机上完成。你没有 root 权限访问物理机。但是你可以用
物理机来测试虚拟机上要求完成的配置

###########
# 请注意: #
###########
因为考试系统时虚拟机,所以你需要使用桌面上的 vm console 图标来访问虚拟机。
您也可以通过 ssh 从桌面系统来访问虚拟机。但是您还没有完成相关考试要求前,是不能通过 ssh 访问虚拟机的。

###########
# 请注意: #
###########
在考试期间 不允许和其他考生交流。也不允许尝试连接其他考生的主机。
测试系统和网络都在监控之中,上述两种情况的发生可能导致您考试成绩为零。

################
# 其他配置信息 #
################

您在考试中将使用两个系统的信息如下:
serverx.example.com 是一个主要的服务器
dekstopx.example.com 主要用作客户端
(x是您的考试号)

两个系统的 root 密码为 redhat


系统的 ip 有 dhcp 提供,您可以视其为正常。或者您可以按照以下信息重新
配置静态IP
serverx.example.com 172.25.x.11
desktopx.example.com 172.25.x.10
子网掩码为 255.255.255.0
(x是您的考试号)


您的系统时 dns 域 example.com 的成员,所有 dns 域 example 中的系统都在子网172.25.x.0/24 中,
同样在这个子网中的系统都在 example.com DNS域中。除非特别声明

classroom.example.com 提供了集中认证的服务域 EXAMPLE.COM.
两个系统 serverx 和 desktopx 已经预先配置成次域的客户端。
此域提供了下列账号
用户:ldapuser1 
密码:kerberos

防火墙默认是打开的,在您认为适当的时候可以关闭,其他火墙的设定可能在单独的要求中。

###############################
# 在评分中签您的系统会被从启。#
###############################

########################################################################################

########
# 题目 #
########

1.配置 selinux
Selinux 必须在两个系统 serverx 和 desktop 中运行 Enforcing 模式

2.配置 ssh 访问
用户能从域 example.com 内的客户端通过 ssh 远程访问您的两个虚拟系统
在域 my133.org 内的客户端不能访问您的两个虚拟机

3.自定义用户环境
在系统 serverx 和 desktopx 上穿件自定义命令 qstat 此命令将执行一下命令:
/bin/ps -Ao pid,tt,user,fname,rsz
此命令对系统中所有用户有效

4.配置端口转发
在系统 serverx 中配置端口转发
在 172.25.x.0/24 网络中的系统,访问 server1 的本地端口 5423 将被转发到 80 此设定时永久生效的

5 配置链路聚合
在 server1.example.com 和 desktopx.example.com 之间按以下要求配置一个链接
此链路使用 eth1 和 eth2
此链路在一个接口失效时扔能正常工作
此链路 serverx 使用地址 172.16.x.65/24
此链路 desktopx 使用的地址 172.16.x75/24
此链路在系统重启之后仍然保持正常状态

6.配置 ipv6 地址
在您的考试系统上配置接口 eth0 使用下列 ipv6 地址
serverx 上的地址 2018:ac18::10a/64
desktopx 上的地址 2018:ac18::11b/64
两个地址可以通信,并且在从新启动后依然生效,两快网卡的 ipv4 地址依然生效

7.配置本地邮件服务
在系统 serverx 和 desktopx 上配置邮件服务
这些系统不接收外部发送来的邮件
这些系统上发送的任何邮件都会自动路由到 classroom.example.com
这些系统上发送的邮件显示来自 example.com
您可以通过用户 hal 来测试您的配置,访问:
http://classroom.example.com/exam_mail/hal.txt
(x是您的考试号)

8.通过 smb 共享目录
在 serverx 上配置 smb 服务
您的 smb 服务必须时 STAFF 工作组的一个成员
共享/groupdir 目录共享名必须是 common
只有 example.com 域的客户可以访问 common 共享
Common 必须时可以浏览的
用户 barney 必须能够都取共享的内容,如果需要的话验证密码是 westos

9.smb 多用户挂在配置
在 serverx 共享通过 smb 目录/data
共享名称 data
共享目录 data 只能被 example.com 域中的客户使用
共享目录 data 必须可以被浏览
用户 manager 必须能一读的方式访问此共享,访问密码时 westos
用户 wolferyne 必须能够一读写的方式访问此共享,访问密码时 westos
此共享永久挂载到 desktopx 主机的 /mnt/westos 目录 , 并使用用户 manager 作为认证
任何用户通过用户 wolferyne 来临时获取写的权限  ???????

10.配置 NFS 服务
在 serverx 配置 nfs
以只读的方式共享目/public 能被 example.com 域中的系统访问
以读写的方式共享目录/protected 能被 example.com 域中的系统访问
访问/protected 需要通过 kerberos 安全加密,您可以使用下面的 url 提供的秘钥
http://classroom.example.com/pub/keytabs/serverx.keytab
目录/protected 应该包含名称为 restricted,拥有人为 ldapuser1 的子目录
用户 ldapuser1 能够使用读写的方式访问/protected/restricted


11.挂在一个 nfs 共享
在 desktopx 上挂在一个来自 serverx.example.com 的 nfs 共享 /public 挂在在下面的目录上/mnt/nfsmount
/protected 挂载在下面目录上/mnt/nfssecure 病且使用安全方式访问,秘钥:
http://classroom.example.com/pub/keytabs/desktopx.keytab
用户 ldapuser1 能够在/mnt/nfssecure/restricted 上创建文件这些文件系统在开机启动时自动挂载


12.实现一个 web 服务器
在 serverx 上配置一个站点 http://serverx.exampmle.com从
http://classroom.example.com/pub/materials/station.html
下载文件,并且将文件重名名为 index.html 不要修改该此文件的内容
将文件 index.html 拷贝到您的 web 服务器的 Documentroot 目录下
来自 example.com 域的客户可以访问此 web 服务
来自 my133t.org 域的可以端拒绝访问此 web

13.配置安全 web 服务
站点 https://westos.example.com 配置 tls 加密一个已签名的证书
从 http://classroom.example.com/pub/tls/certs/westos.crt
从 http://classroom.example.com/pub/tls/private/westos.key
从 http://classroom.example.com/pub/example-ca.crt

14.配置虚拟主机
在serverx上拓展您的web服务器,为站点 
http://wwwx.example.com 创建一个虚拟主机
设定默认发布目录为/var/www/virtual
从classroom.example.com/pub/materials/www.html 下载文件并
重命名为 index.html,不要对文件 index.html 的内容做任何修改
将文件 index.html 放到默认发目录下
确保 barney 用户能在/var/www/virtual 目录下创建文件

15.配置您的 serverx 上的 web 服务器
在默认发布目录下创建一个名为 confidential 的目录从
http://classroom.example.com/pub/materials/private.html
下载到这个目录中,并且重命名为 index.html
不要修改这个文件的内容
从 serverx 上,任何人都可以浏览此目录,但是其他系统不能访问此目录中的内容

16.实现动态 web 内容
在 server1 上配置提供 web 内容
动态内容由名为 transitive.example.com 的虚拟机提供虚拟机监听端口:8989
从 http://classroom.example.com/pub/materials/script.wsgi
下载一个脚本,然后防到合适的位置,不要修改该此文件内容
客户访问 http://transitive.example.com:8989时应该生成动态的web页面
此站点 必须能被 example.com 域内的所有系统访问


17.创建一个脚本
在 serverx 上创建一个/root/scripts.sh 的脚本,让其提供下列特性
当运行/root/scripts.sh all 输出 none
当运行/root/scripts.sh none 输出 all
当没有任何参数或者参数不时 all 或 none 时,其错误输出产生下列信息


18.配置 iscsi 服务端
配置serverx提供一个iscsi服务磁盘名称 
iqn.2014-11.com.example:serverx端口 3260
用 iscsi_data 作为后端卷,大小为 3G
此服务只能被 desktopx.example.com 访问

19.配置 iscsi 的客户端
配置 desktopx 使其能链接在 server1 上提供的 iscsi
iscsi 设备在系统启动的期间自动加载
块设备 iscsi 上包含一个大小为 1900M 的分区,并格式化为 xfs
此分区自动挂载在/mnt/data 上同时在系统启动的期间自动挂载


20.配置一个数据库
在 serverx 上创建一个 mariadb,名为 Contacts
数据库应该包含来自数据库复制的内容。复制文件的 url
http://classroom.example.com/pub/materials/users.mdb
数据库只能被 localhost 访问
除了 root 用户,此数据库只能被 Luigi 查询,此用户密码为 westos
超级用户密码为 westos,同时不允许空密码登陆

21.查询数据库
在系统 serverx 上使用数据库 contacts,并且使用相应 sql 查询以回答
下列问题 密码 forsook 的人的名字
Brian
select id from User_logins where User_pass = ‘forsook’
select first_name from User_Names where user_id = ‘4178’

有多少人的姓名时 Alan 同时居住在 Cupertino
152


4e643d52-4404-49e2-b6ce-329104313b2a
