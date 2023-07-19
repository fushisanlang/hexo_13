---
title: sfpt服务搭建
date: 2019-1-23
updated: 2019-1-24
categories:
  - note
abbrlink: f39d9b43
---
    ssh –V  #来查看openssh的版本，如果低于4.8p1，需要自行升级安装，
    groupadd sftp  
    useradd -g sftp -s /bin/false testuser   
    passwd testuser
    mkdir /opt/sftp   
    cd /opt/sftp;      
    mkdir testuser
    usermod -d /opt/sftp/testuser testuser
    vim /etc/ssh/sshd_config
        #Subsystem   sftp    /usr/libexec/openssh/sftp-server  #注释掉
        Subsystem       sftp    internal-sftp  
        Match Group sftp  
        ChrootDirectory /opt/sftp/%u  
        ForceCommand    internal-sftp  
        AllowTcpForwarding no  
        X11Forwarding no    //添加
    chown root:sftp /opt/sftp/testuser 
    chmod 755 /opt/sftp/testuser   ##要是限制ftp用户根目录，则需要将改根目录属主设为root，权限最多为755
    service sshd restart  
    mkdir /opt/sftp/testuser/upload  
    chown uplus:sftp /opt/sftp/testuser/upload  
    chmod 755 /opt/sftp/testuser/upload   #新建上传目录，上层目录只读
    sftp mysftp@127.0.0.1    #测试