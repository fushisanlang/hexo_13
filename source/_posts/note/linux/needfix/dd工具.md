---
title: dd工具
date: 2019-6-18
updated: 2019-6-19
categories:
  - note
abbrlink: 6c79f6b6
---
    dd if=/dev/xvdb1 of=test4 bs=1000M count=1
    
    dd 命令
    if=/dev/xvdb1   截取的位置
    of=test4    截取的文件
    bs=1000M    截取的单块大小
    count=1     截取的块数