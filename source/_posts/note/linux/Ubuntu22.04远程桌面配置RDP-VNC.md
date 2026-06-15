---
title: Ubuntu22.04远程桌面配置（RDP，VNC）
date: 2026-06-15
tags:
  - ubuntu
  - linux
  - rdp
  - vnc
  - 远程桌面
categories:
  - note
---

Ubuntu 22.04 设置远程桌面可以通过 Gnome42 内置的远程功能，或手动安装 RDP 或 VNC 软件。

<!--more-->

## 一、通过 Gnome42 内置的远程功能

在 Ubuntu Desktop 22.04 LTS 上，远程桌面服务被配置为用户服务。必须登录系统才能启动远程桌面服务。

**注意：** 如果想在无人值守模式下远程使用 Ubuntu（无需连接显示器、键盘和鼠标），建议启用自动登录。Ubuntu 默认启用屏幕空白和自动屏幕锁定，空闲一段时间后会断开连接。这个功能更适合远程协助。

### 配置步骤

1. 从系统托盘菜单中打开系统设置（Gnome 控制中心）
2. 从左侧导航到"共享"，打开右上角的切换图标，点击"Remote Desktop"
3. 启用远程桌面，设置远程访问的用户密码

- 启用1：可以通过 Windows 的 RDP 访问 Ubuntu 的远程桌面
- 启用2：可以控制远程桌面
- 不启用：只能查看

## 二、手动安装XRDP（推荐）

手动安装不需要考虑系统登录的问题及屏幕空白和锁屏的问题。

### 什么是 XRDP？

XRDP 是一个免费的开源程序，是 Microsoft RDP（远程桌面协议）的实现，可通过 GUI 轻松远程访问 Linux 系统。

### 1. 执行系统更新

```bash
sudo apt update
```

### 2. 安装 XRDP

```bash
sudo apt install xrdp
```

### 3. 启动并启用 XRDP 服务

```bash
sudo systemctl start xrdp
sudo systemctl enable xrdp
systemctl status xrdp
```

### 4. 在防火墙中打开3389端口

```bash
sudo ufw allow from any to any port 3389 proto tcp
```

查看 IP 地址：

```bash
ip a
```

### 5. 注销 Ubuntu 22.04

安装完成后，需要注销 Ubuntu 22.04 系统，否则在使用 XRDP 远程连接时会遇到黑屏问题。

点击"关机"图标，选择"注销"。

之后就可以通过 Windows 的远程桌面访问 Ubuntu 了，登录账号密码就是 Ubuntu 的系统账号密码。
