---
title: cifs
date: 2017-10-19
updated: 2017-10-20
categories:
  - note
abbrlink: b57a9bf9
---
* cifs


    yum install samba-client
    smbclient -L //ip
    smbclient //ip/sharename
    #或
    mount //ip/sharename /mountpoint -o username=guest
    vim /etc/fstab
    //ip/sharename /mountpoint cifs	defaults,username=guest 0 0
    mount -a
