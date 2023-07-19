---
title: xen主机异常问题记录
date: 2019-11-25
updated: 2019-11-26
tags:
  - xen
categories:
  - note
abbrlink: bafb4095
---


### 现象
通过xencenter连接xen主机，对虚拟机进行复制，开关机等操作时卡死。
在命令行模式，使用 `xe vm-reset-powerstate force=true uuid=XXX`  ， `xe vm-start uuid=XXX` 命令也卡死，无法操作虚机。
通过命令行模式，`xe task-list` 查看任务时，发现除了刚刚执行的任务是 `pending` 状态。还有一个sr的scan任务也是 `pending` 状态。通过 `xe task-cancel uuid=XX` 命令取消任务也没有返回。
联想到之前查看nfs iso library时，无法正常连接的问题，猜测是nfs挂载异常导致的问题。
通过 `df -h` 命令查看挂载情况，发现命令卡死。
通过 `strace df -h` 查看，果然是卡在 `/run/sr-mount/**` 的挂载点。
基本跟猜想的情况一致。
<!--more-->
### 处理过程
首先通过xshell登录xen主机，通过 `mount` 命令查看了挂载情况。发现异常的 `/run/sr-mount/**` 的挂载点就是 `nfs` 。
然后使用 `umount -l /run/sr-mount/**` 命令解除挂载。
解除后 `df -h` 命令可以发现，其他的磁盘及挂载都可以正常显示，第一步完成。

之后通过 `xe task-list` 命令查看一下主机上挂起的任务，通过 `xe task-cancel uuid=XX` 手动取消掉。** 我在进行这一步的操作时，发现无法取消掉，但是应该不影响之后的操作。xencenter的管理已经可以正常使用了。 **

之后使用 `xe vm-list` 查看虚拟机状态，找到之前启停异常的虚机，通过 `xe vm-reset-powerstate force=true uuid=XXX` 强制关机，将状态置为关机状态.
然后使用 `xe vm-start uuid=XXX` 命令启动虚机。
我在这一步之后，已经可以正常操作虚机的启停了。使用xencenter也可以正常操作。

最后，看了一下nfs的情况，发现是nfs的服务异常，导致nfs无法使用。 尝试修复之后发现问题依旧，为了防止下次xenserver主机重新出现异常，决定接触掉nfs挂载。
在xencenter界面中，点击相应的库，发现没有forget选项，而且扫描的时候，确实无法连接到nfs库。所以决定通过命令行解除。
首先通过 `xe sr-list` 查看挂载情况，找到iso库的uuid。
使用 `xe sr-list uuid=d24714e4-3825-edee-b8e0-330fc575881a` 确认是否正确。
然后通过 `xe pbd-list  sr-uuid=d24714e4-3825-edee-b8e0-330fc575881a` 找到PBD的uuid。
通过解除使用。
在这一步的时候，发现有异常报错，猜测是有虚拟机的光驱挂载了库里的镜像。挨个查找之后果然找到有两个虚拟机的光驱中有镜像。
通过xencenter弹出光驱后，重新执行该命令，正常解除掉了挂载。

解除使用后，通过 `xe  pbd-unplug uuid=e6b0bf61-6e9d-704b-f950-f84700dc89a6` 确认是否解除成功。
没有返回即为解除成功。
最后，通过 `xe  sr-forget uuid=d24714e4-3825-edee-b8e0-330fc575881a` 命令遗忘iso库。
这时，通过 `xe sr-list` 已经没有异常的nfs库了。
在xencenter也找不到了。
操作完成。

### 总结
在这次异常的处理中，并未第一时间猜想nfs挂载的问题。因为之前在这台xenserver上敲过 `df` 命令，可以正常显示，但是那个时候nfs已经有问题了。因为不需要新添加虚拟机，也就没重视。
查找的方向还是先去看了xapi相关的东西。但是因为不敢轻易重启xapi服务，所以没有解决问题。
猜测如果直接重启xapi服务，应该也可以解决该问题。但是不推荐使用。因为xapi重启后，虚机可能有影响，甚至整个xenserver主机都要硬重启，牵扯太多。

所以下次还是要记得，服务器异常的时候，内存，磁盘，负载这些先看一下，可以节省很多时间。
