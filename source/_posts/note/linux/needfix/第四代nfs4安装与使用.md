---
title: 第四代nfs4安装与使用
date: 2016-1-19
updated: 2016-1-20
tags:
  - nfs
categories:
  - note
abbrlink: 61006a97
---
### 环境：

 server：192.168.1.144 Linux version 2.6.18-308.el5PAE   
 client： 192.168.1.136 Linux version 2.6.18-308.el5PAE   
 在centos6.7环境下测试时也正常。


### server端：

    yum install -y nfs4-acl-tools nfs-utils
    vim /etc/exports
        /share 192.168.1.136(fsid=0,rw,async,no_root_squash)
    # fsid=0  nfs4特有的参数，只能有一个目录。这个目录将成为nfs服务器的根目录。（所以下文挂载时为144：/ 而非144：/share）
    # rw 读写、async NFS在写入数据前可以相应请求、 no_root_squash root用户具有根目录的完全管理访问权限
    mkdir /share
    chmod 777 /share
    service nfs start
    
    
    
### client端：

    yum install -y nfs4-acl-tools nfs-utils
    showmount -e 192.168.1.144
    mount -t nfs4 192.168.1.144:/ /mnt/144share/
    # 上文提到的，nfs通过fsid=0参数确认了一个根目录。
    nfsstat -m #用来查看挂载信息