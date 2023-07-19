---
title: SVN账户添加
date: 2018-3-11
updated: 2018-3-12
categories:
  - note
abbrlink: e922a15f
---
## **SVN账户添加**

svn所在服务器 192.168.2.8

* 更改用户权限

    
    vi /data/svn/conf/authz.conf
        #通过目录或者用户进行定位，然后更改权限
        #新的账户需要单独增加一行
        
* 新建账户

命名规则举例：张引 命名yzhang，如有重名适当更改
首先在上述文件中查找是否有重名账户，确保用户名可用
    
    sh /data/programe/usercreate.sh 
        #密码尽量与用户名相同
    
