---
title: ulimit和内核优化
date: 2017-9-1
updated: 2017-9-2
categories:
  - note
abbrlink: 1fe2886a
---
ulimit

    vim /etc/security/limits.d/90-nproc.conf

    vim /etc/security/limits.conf


内核

    vim /etc/sysctl.conf


查看句柄及PID

    lsof -n|awk '{print $2}'|sort|uniq -c|sort -nr|more