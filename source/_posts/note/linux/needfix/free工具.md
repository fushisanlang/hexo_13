---
title: free工具
date: 2018-9-14
updated: 2018-9-15
categories:
  - note
abbrlink: 82a0d5e7
---
如下显示free是显示的当前内存的使用,-m的意思是M字节来显示内容.我们来一起看看.

    $ free -m
    total used free shared buffers cached
    Mem: 1002 769 232 0 62 421
    -/+ buffers/cache: 286 715
    Swap: 1153 0 1153

第一部分Mem行:
total 内存总数: 1002M
used 已经使用的内存数: 769M
free 空闲的内存数: 232M
shared 当前已经废弃不用,总是0
buffers Buffer 缓存内存数: 62M
cached Page 缓存内存数:421M

关系：total(1002M) = used(769M) + free(232M)

第二部分(-/+ buffers/cache):
(-buffers/cache) used内存数：286M (指的第一部分Mem行中的used – buffers – cached)
(+buffers/cache) free内存数: 715M (指的第一部分Mem行中的free + buffers + cached)

可见-buffers/cache反映的是被程序实实在在吃掉的内存,而+buffers/cache反映的是可以挪用的内存总数.

第三部分是指交换分区, 我想不讲大家都明白.

 

大家看了上面,还是很晕.第一部分(Mem)与第二部分(-/+ buffers/cache)的结果中有关used和free为什么这么奇怪.


其实我们可以从二个方面来解释.
**对操作系统来讲是Mem的参数.buffers/cached 都是属于被使用,所以它认为free只有232.**

**对应用程序来讲是(-/+ buffers/cach).buffers/cached 是等同可用的,因为buffer/cached是为了提高程序执行的性能,当程序使用内存时,buffer/cached会很快地被使用.**