---
title: selinux
date: 2020-6-3
updated: 2020-6-4
categories:
  - note
abbrlink: 4ce63b73
---
* 什么是selinux

selinux，内核级加强型防火墙

*  如何管理selinux级别


    vim /etc/sysconfig/selinux
        selinux=disabled		##关闭状态
        selinux=Enforcing		##强制状态
        selinux=Permissive		##警告状态

    getenforce			##查看状态
    #当selinux开启时
    setenforce 0|1			##更改selinux运行级别
    #0 Permissive
    #1 Enforcing

* 如何更改文件安全上下文

 临时更改

    chcon -t 安全上下文	文件
    chcon -t public_content_t /publicftp -R

永久更改

    semanage fcontext -l		##列出内核安全上下文列表内容
    semanage fcontext -a -t public_content_t '/publicftp(/.*)?'
    restorecon -FvvR /publicftp/

* 如何控制selinux对服务功能的开关


    getsebool -a | grep 服务名称
    getsebool -a | grep ftp
    setsebool -P 功能bool值 on|off
    setsebool -P	ftpd_anon_write on

* 监控selinux的错误信息

setroubleshoot-server


    semanage fcontext -a -t public_content_t '/westos(/.*)?'
    restorecon -FvvR /westos/
    ls -Zdl /westos/

