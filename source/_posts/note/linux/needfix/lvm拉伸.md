---
title: lvm拉伸
date: 2019-11-18
updated: 2019-11-19
categories:
  - note
abbrlink: 695bf1f7
---

    fdisk -cu /dev/vdb
    #分区后，通过t选项将vdb1的类型改为8e。

    pvcreate /dev/vdb1
    vgextend VolGroup /dev/vdb1   
    #此处的VolGroup时root所在的逻辑卷组，可以通过vgs命令查询。
    lvextend -L +20G /dev/VolGroup/lv_root    
    #此时可能出现可用空间不足的错误，可以通过添加pe个数的方式扩容
    #具体可用pe个数会在报错中显示
    lvextend -l +5119 /dev/VolGroup/lv_root  
    #此时，在逻辑层面完成了root的扩容，但是文件系统并未识别扩容。
    resize2fs /dev/VolGroup/lv_root    
    #此时，通过 df -sh命令，可以看见root的大小增加了20g。