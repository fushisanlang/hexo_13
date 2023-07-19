---
title: xenserver 创建本地iso库
date: 2020-12-27
updated: 2020-12-28
tags:
  - xenserver
categories:
  - note
abbrlink: 5aa581e
---
### 创建


```shell
xe sr-create name-label=ISO type=iso device-config:location=/iso  device-config:legacy_mode=true content-type=iso
```


### 删除

首先， 运行下面的命令来确定SR的UUID：

```shell
xe sr-list name-label=<Name of the SR>
```

其次，确定对应PBD的UUID：

```shell
xe pbd-list sr-uuid=<UUID of SR>
```

再次，断开PBD：

```shell
xe pbd-unplug uuid=<UUID of PBD>
```

最后，删除记录

```shell
xe sr-forget uuid=<UUID of SR>
```