---
title: rhcsa模拟题
date: 2020-7-1
updated: 2020-7-2
tags:
  - rhcsa
  - exam
  - need fix
categories:
  - note
abbrlink: 7ee59806
---
考试说明
考试时有套注册系统,需要填写自己的信息,全英文,
名字时证书上的名字
Timimg_Lee 
邮箱
用 qq 邮箱,建议用
真实系统密码不能进入超级用户
有自己的一套管理系统
Rebuild exam 不要点。
其他信息
您的机器时 example.com 域的一个成员。Example.com 域的所有系统在 172.25.1.0/24 子
网内。并且所有在这个子网的系统都属于 example.com 域。
虚拟机的网络配置如下:
主机名称:serverx.example.com
Ip 地址:172.25.x.11
子网掩码:255.255.255.0
网关:172.25.1.254
服务器名称:172.25.254.254
虚拟机的 root 密码修改成 modtweed
您必须完成对网络的修改才能访问其余的考题,一但完成修改该,前几下面的链接:
http://rhcert.domain13.example.com/cgi-bin/protal.cgi
如果您已经成功完成初始的题目,您将被重新定向到考试的其余部分。
在评分之前您的系统会被从新启动,所以请您确保您所做的所有修改该在重新启动之后
依然能够生效。
并且您也需要知道。评分的标准是系统能不能按照题目所规定的要求正常工作,因此,
如果您的网络本身没有启动,即使配置正确也不能得分。您在考试中使用的 Red Hat Enterprise Linux 操作系统半分对应的分发包可以通过 yum
在 下面的链接中找到:
http://content.example.com/rhel7.0/x86_64/dvd 意一些考试题目可能依赖与其他考试题目,
比如说,在考试题目中肯能要求您针对一个用户执行一系列的限制,但是这个用户的创
建可能时在其他题目中要求的。
为了方便您的表示,每个考试题目都由一些单选俺有以协助您区标示那个题目已经完成
了。那个题目还没有。当然,如果您觉得用不着,您可以不去理会这些按钮,除了让您
能够简单标识每个题目的状态之外,这些按钮没有其他任何用处。
虚拟机系统信息
如果您要访问您的虚拟系统的控制台,可以点击您桌面上的《考试虚拟机控制台》图标
在考试期间,您可以随意关闭或者重新启动您的虚拟机,您可以在虚拟机内中兴这些操
作或者使用物理机控制虚拟机
在物理机上访问或者控制您的考试系统,您可以点击您桌面上的《虚拟机控制》图标,
会显示一个有四个选项的目录
Start exam vm 开启虚拟机
Reboot exam vm 重启虚拟机
Pow eroff exam vm 关闭虚拟机
Exam vm console 显示虚拟机,ctrl+alt 鼠标解除控制
Rebuild exam vm
考试题部分
附加题:
1.修改 root 密码

2.修改该网络配置

考试题部分
要求
重置虚拟机完成下列操作,当您收到成绩时,这部分内容的成绩会标示为 rhcsa,并且您必须得到
300 分中的 210 分级以上才能获得此认证
1. 配置 SELinux
a)
SELinux 必须时 enforcing

2.为您的系统配置一个默认的软件仓库
a) Yum 的软件 http://content.example.com/rhel7.0/x86_64/dvd 将此配置为您的系统
默认软件仓库

3.调整逻辑卷的大小
a) 将逻辑卷 vo 和其文件系统大小调整到 230M ,确保文件系统中的内容保持完整
b) 请注意:分区大小很少能够完全符合要求的大小,所以在 217M 和 243M 之间
都时可以的

4.创建用户账号
a) 创建下列用户,组,和组的成员关系
b) 一个名为 sysmgrs 的组
c) 一个名为 natasha 的用户,其属于 sysmgrs,这个组是该用户的从属组
d) 一个名为  的用户,属于 sysmgrs,这个组是该用户的从属组
e) 一个名为 sarah 的用户,其在系统汇总没有可以交互的 shell,并且该用户不是
sysmgrs 的组成员
f) 用户 natsha,harry,sarah 的秘密吗都要设定为:modteed

5.配置文件/var/tmp/fstab 的权限
a) 拷贝文件/etc/fstab 到/var/tmp/fstab 配置文件/var/tmp/fstab 的权限
b) 文件/var/tmp/fstab 的拥有者是 root
c) 文件/var/tmp/fstab 属于 root 组
d) 文件/var/tmp/fstab 对任何用户不可执行
e) 用户 natasha 能够对文件/var/tmp/fstab/具有读写权限
f) 用户 harry 对文件/var/tmp/fstab 既不能读也不能写
g) 其他用户(当前和将来的)能对文件/var/tmp/fstab 进行读操作

6.配置一个 cron 任务
a) 用户 natasha 必须配置一个定时任务,每天在本地时间 14:23 时执行命令
/bin/echo hiya

7.创建一个共享目录
a) 创建一个共享目录/home/managers 特性如下
b) /home/managers 目录的所有权时 sysmgrs
c) Sysmgrs 组成员对目录有读写和执行的权限。初此之外的其他所有用户没有任
何权限(root 用户除外)
d) 在/home/managers 目录中创建的文件,其组所有权会自动设置为属于 sysmgrs
组

8.安装内核的升级
a) 从 http://172.25.x.254/update 升级正确的内核
b) 当系统重新启动之后升级的内核要作为默认内核
c) 原来的内核要被保留,并且仍然可以正常启动

9.绑定到外部验证服务a)
b) 系统 classroom.example.com 提供了一个 ldap 验证服务
   验证服务器 dn 是:dc=example,dc=com
c) 账户信息和验证信息都是 ldap 提供
   链接需要使用的证书进行加密,证书可以在下面的链接中下载:
   http://classroom.example.com/pub/example-ca.crt
d) 当正确完成配置后,用户 ldapuser1 应该能够登陆到您的系统中,但是没有
   家目录,当完成 autofs 的题目之后才有
   用户 ldapuser1 的密码时 password

10.配置 ntp
a) 配置您的系统,让其作为一个 classroom.example.com 的 ntp 客户端

11.配置 autofs
a) 配置 autofs 实现 ldap 用户家目录自动挂载
b)
Classroom.example.com(172.25.254.254)通过 nfs 输出了/home/guests 目录到您
的系统这个目录中包含了用户 ldapuser1 的主目录,并且已经预先设定好了
c)
Ldapuser1 的家目录时 classroom.example.com:/home/guests/ldapuser1
d) Ldapuser1 的家目录应该挂载到本地的/home/guests/ldapuse1 目录下并且读写挂载，nfs挂载版本为3
e)
用户对其主目录必须可以写
f) Ldapuser1 用户密是 password

12. 配置一个用户
a) 创建一个名为 manalo 的用户,用户 id3533 密码时 modteed
13. 添加一个 swap 分区
a)
在系统中添加一个大小为 756M 的 swap 分区,当您的系统自动启动时,swap
可以自动挂载

14. 查找文件
a)
找出所有用户 jacques 拥有的文件,并且吧他们的拷贝放到/root/findfiles 目录
中

15. 查找一个字符串
a)
在文件/usr/share/xml/iso-codes/iso_639_3.xml 中查找到所有包含字符 ng 的行
b)
将找出的行按照先后顺序复制到/root/list 文件中。/root/list 文件不要包含空行
c)
其中的所有行的内容必须时源文件中原始的标准副本

16.归档一个文件
a) 创建一个名为/root/backup.tar.gz 的归档文件,其中包含/usr/local 目录中的内容,
tar 归档文件必须使用 gzip 进行压缩

17.创建一个逻辑卷
a)
逻辑卷名称为 qa,属于 qagroup 卷组,并且逻辑卷的大小为 60 个物理扩展单
元
b)
qagroup 卷组中的逻辑卷物理扩展单元为 16M
c)
使用 ext3 文件系统格式并且自动挂载到/mnt/qa 目录下

