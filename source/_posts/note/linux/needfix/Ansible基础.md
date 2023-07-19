---
title: Ansible基础
date: 2017-3-12
updated: 2017-3-13
categories:
  - note
abbrlink: 597889c5
---
# Ansible基础



### 服务结构

> IAAS:基础设施即服务，硬件。
>
> PAAS：平台即服务，系统，中间件。
>
> SAAS：软件即服务，整个平台。



### 安装

```shell
#yum方式安装，需要事先安装epel源
yum install ansible
#或者可以使用编译安装，或者从git下载代码即可。
ansible --version  #查看版本，验证安装是否成功
```



### 主机清单

``` shell
vim /etc/
```

