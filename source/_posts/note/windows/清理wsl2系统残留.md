---
title: 清理wsl2系统残留
tags:
  - windows
categories:
  - windows
  - wsl2
abbrlink: d2b1431b
date: 2023-10-24 00:00:00
---

```powershell
wsl --shutdown #关闭wsl2

diskpart  # 运行diskpart 

diskpart> select vdisk file="{vhdx文件名}" # 指定磁盘文件，存储位置一般在如下地址：C:\Users\Administrator\AppData\Local\Packages\CanonicalGroupLimited.UbuntuonWindows_xxx\LocalState\ext4.vhdx

diskpart> compact vdisk   # 等待压缩完成即可
```
