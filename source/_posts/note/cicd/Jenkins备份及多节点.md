---
title: Jenkins备份及多节点
date: 2020-10-25
updated: 2020-10-26
tags:
  - qa
  - jenkins
  - need fix
categories:
  - note
abbrlink: a9c98372
---

### 一、Jenkins备份及多节点

#### 1、安装ThinBackup

备份jenkins通过第三方插件 ThinBackup 进行
登录已有jenkins进行安装ThinBackup插件:
Jenkins --> 系统管理 --> 插件管理 --> 搜索ThinBackup 下图是已经安装好了
![技术分享图片](img/e9d8d7911df20041fde1706cad1fb781.png)

#### 2、配置ThinBackup

Jenkins --> 系统管理 --> ThinBackup --> Setting -->如图:
![技术分享图片](img/e1290a1ee9fce8850c06baa10a18b4ae.png)

![技术分享图片](img/97c5f6f5d423220cbb4355dd6762d7e2.png)

以上配置表示周一到周五12点1分完整备份到/mnt/jenkins_bak (NFS共享中)
备份内容包括:build results、Backup userContent folder、Backup next build number file
Backup plugins archives(插件)、 Backup additional files、以及把老的备份文件打包压缩
手动执行备份:
Jenkins --> 系统管理 --> ThinBackup --> Backup Now
注意此时页面像是卡住了(等待备份响应),实际上jenkins在后台运行备份程序,可以通过到备份目录中查看
目录大小看到,已经生成了备份目录类似 "FULL-2018-11-06_21-01"
备份完成页面就正常了~

<!--more-->
### 二、通过备份进行恢复Jenkins

#### 1、环境准备

假设现有的jenkins已经损坏不能正常使用;需要通过最近的完整备份恢复jenkins服务;
首先部署jenkins 请参考步骤一;挂载NFS共享目录到本地(因为之前的jenkins自动备份是放在NFS中)
或复制完成备份到新的jenkins主机上;新的jenkins安装第三方备份还原插件ThinBackup;

#### 2、配置ThinBackup并备份

还原操作在10.8.11.228上即上面新安装的jenkins上操作，步骤如下：
先设置备份与还原的配置：
Jenkins --> 系统管理 --> ThinBackup --> Setting -->如图:
![技术分享图片](img/ba4a862f433c9cd0138d42b7bc894b2d.png)

#### 3、还原jenkins

Jenkins --> 系统管理 --> ThinBackup --> Restore 如图:
![技术分享图片](img/8d1967a078895f9208df54fa6a606903.png)

如图钩选上
Restore next build number file(build文件)
Restore plugins(还原插件)
点击Restore 同样需要等待一段时间;可以查看/var/lib/jenkins目录的变化;

#### 4、还原注意项

jenkins还原后可能出现以下插件没有更新情况如图(不影响还原后使用):
![技术分享图片](img/a9d8e6ae7c5ee0f0c7f449fdb52c1bb8.png)

以下显示的有红色提示的表示更新后的新插件版本会影响现有功能使用,需要重新配置才可以;因此需要谨慎更新;
如图:
![技术分享图片](img/0f3a80c1925fde2d51ab7a080ad2fef2.png)
没有提示的可以直接到插件中进行更新操作;

还原后会发现所有的从节点变成offine状态不可用;如还原后从节点10.8.11.240状态是offine
点击从节点测试可能出现如下情况:

```
[06/11/18 10:03:51] [SSH] Opening SSH connection to [AGENT_HOSTNAME]:22.
[06/11/18 10:03:51] [SSH] WARNING: No entry currently exists in the Known Hosts file for this host. Connections will be denied until this new host
and its associated key is added to the Known Hosts file.
Key exchange was not finished, connection is closed.
java.io.IOException: There was a problem while connecting to [AGENT_HOSTNAME]:22
```

原因是缺少/var/lib/jenkins/.ssh/known_hosts文件(里面是jenins到各从节点的应答指纹信息)
需要在/var/lib/jenkins工作队目录下创建.ssh目录并修改为
jenkins用户和组所有权限700 对所有从节点手动访问一次用来接受ssh应答指纹;
在新的jenkins上 ssh root@10.8.11.240 此时/root/.ssh/known_hosts中有一条记录

复制/root/.ssh/known_hosts 到/var/lib/jenkins/.ssh/下
权限如下:

```text
-rw------- 1 jenkins jenkins 2.6K 11月 6 18:08 known_hosts
```

如是从节点是无密码私钥认证请记得把私钥放在/root/.ssh/下叫id_rsa 公钥放到对应从节点的用户下
/root/.ssh/authorized_keys文件中并确保权限为
-rw------- 1 root root1 .2K 12月 12 2017 authorized_keys
ssh -p 65022 root@10.8.11.246 无密码登录上10.8.11.246则表示配置正常;
重复以上操作从新jenkins上登录所有从节点再把known_hosts复制到/var/lib/jenkins/.ssh/下 直到所有从节点
的应答指纹都在存在;

#### 5、以ssh 私钥添加从节点

Jenkins -->系统管理--> 节点管理--> New Node --> Node name -->固定节点 如图:
![技术分享图片](img/a528b77d2b3c93f28e7e0625d6e8e788.png)
![技术分享图片](img/d73fc1637e30f9c3c6ce01bc109f28f2.png)
点击 “Credentials” Add 添加jenkins与从节点通讯方式为ssh 私钥 并粘贴私钥文件
如图:
![技术分享图片](img/77ae54a60149680f0dfa66f6d6135e92.png)
保存;
再次点击节点测试可以发现 从节点正常啦!

### 三、测试Jenkins使用

下面以TEST-rsyncV3images job 在恢复过来的jenkins上运行，这是用来把线上图片同步到本地所有测试环境中的job:

以下是以恢复过来的Jenkins上测试执行一个job查看是否部署成功与恢复成功～
![技术分享图片](img/42c5580de52437060fd1412ce4ae3f4c.png)
![技术分享图片](img/233d78245277db9cc5da99d025fc75a1.png)
![技术分享图片](img/bda7ea78667b1853aa38b00b67e7311b.png)

到此，jenkins部署配置，以及添加从节点，备份与恢复完成～ 再也不怕jenkins故障导致业务无法部署上线啦，

