---
title: 建立本地yum仓库及建立网络yum仓库
date: 2017-5-21
updated: 2017-5-22
categories:
  - note
tags:
  - yum
abbrlink: '48203e08'
---
### 建立本地yum仓库
```
mv /home/kiosk/Desktop/rhel-server-7.0-x86_64-dvd.iso /iso   #得到iso并保证位置安全      
mount /iso/rhel-server-7.0-x86_64-dvd.iso /westos/     #挂载iso到/westos
vim /etc/yum.repos.d/yum.repo
	[test]
	name=test
	baseurl=file:///westos
	gpgcheck=0
```      
 
### 建立网络yum仓库 
```
mv rhel-dvd.repo rhel-dvd.repo.bak
mv rht-extras.repo rht-extras.repo.bak       #更改yum文件
yum clean all
yum repolist     #更新yum
yum install httpd -y
systemctl start httpd
systemctl enable httpd         #安装http并设置开机启动
systemctl stop firewalld
systemctl disable firewalld         #停止防火墙并设置开机不启动
umount /westos/
mount /iso/rhel-server-7.0-x86_64-dvd.iso /var/www/html/rhel7.0/   #挂载iso在/var/www/html/rhel7.0
vim /etc/yum.repos.d/yum.repo  #更改yum文件，地址设为IP地址
	[test]
	name=local software
	baseurl=http://172.25.28.250/rhel7.0
	gpgcheck=0         
```