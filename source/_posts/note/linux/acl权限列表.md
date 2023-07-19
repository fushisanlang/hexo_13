---
title: acl 权限列表
date: 2016-9-11
updated: 2016-9-12
tags:
  - acl
categories:
  - note
abbrlink: e364e432
---

* 什么是权限列表
  对与文件的权限进行附加补充说明的一个权限设定方式

* 如何去查看权限列表   

<!--more-->

```shell
ls -l test
-rw-r--r--. 1 root root 0 Nov  7 09:14 test
#如果此位为“.”,代表这位上没有权限列表
#如果此位为“+”,代表权限权限列表存在

ls -l file
-rw-rw-r--<<+>> 1 root root 0 Nov  7 09:14 file

getfacl file 
# file: file		##文件名称
# owner: root		##文件所有人
# group: root		##文件所有组
#user::rw-		##所有人权限
#user:student:rw-	##特定用户权限
#group::r--		##所有组权限
#mask::rw-		##特定用户生效的最大权限
#other::r--		##其他人权限
```


* 如何设定acl权限


```shell
setfacl	-m <u|g|m>:<username|groupname>:权限	filename	##设定acl
setfacl -x <u|g>:<username|groupname> 		filename	##去除某个用户或者组的acl
setfacl -b					filename	##删除文件上的权限列表
```

* acl默认权限

默认权限针对目录使用时让目录中所有新建文件都继承此权限，这个权限对目录本身不生效，并且不会影响目录中已经存在的文件

```powershell
setfacl -m d:<u|g|o>:<username|group>:rwx	directory	##设定默认权限
setfacl -x  d:<u|g|o>:<username|group>		directory	##撤销目录中的某条默认权限
```

* 在rhel6以及之前的版本中，用户建立的分区是不支持acl的，如果需要，必须加载acl参数


```shell
mount -o remount，acl	设备
vim /etc/fstab
    设备	挂载点	类型	defaults，acl	0 0
```







