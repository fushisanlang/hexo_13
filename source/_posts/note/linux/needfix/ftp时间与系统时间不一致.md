---
title: ftp时间与系统时间不一致
date: 2017-4-19
updated: 2017-4-20
categories:
  - note
abbrlink: 2e37a4aa
---
ftp服务默认使用的是GMT时区，本地时间多数为CST时区。两者时区不同，所以在使用时，会显示不同的时间。   
具体情况表现为：在本地查看文件的时间是CST时间，但是通过ftp查看文件时，时间就成了GMT时间。    

解决方法：   

    vim /etc/vsftpd/vsftpd.conf 
        use_localtime=YES
    /etc/init.d/vsftpd restart

通过在配置文件中，令ftp使用系统时间即可。

示例：

![image](E://操作/TIM图片20171108094203.png)