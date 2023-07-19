---
title: manjaro 20 i3环境部署记录
date: 2020-9-3
updated: 2020-9-4
tags:
  - manjaro
  - i3
categories:
  - note
abbrlink: cedfcbd1
---
### 配置pacman，生成可用中国镜像

```shell
sudo pacman-mirrors -i -c China -m rank
# 根据提示选择镜像源
```



### 更新系统镜像源

```shell
sudo pacman -Syyu
```

<!--more-->


### 添加archlinux源

```shell
sudo nano /etc/pacman.conf
##在文件结尾处增加
[archlinuxcn]
SigLevel = Optional TrustedOnly
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch

#更新并安装源
sudo pacman -Syy && sudo pacman -S archlinuxcn-keyring
```



### 安装AUR库支持的工具yaourt

```shell
sudo pacman -S yaourt
```



### 安装常用软件

```shell
sudo pacman -S wps-office
sudo pacman -S ttf-wps-fonts #wps

sudo pacman -S vim #vim

sudo pacman -S code #vscode

sudo pacman -S deepin.com.qq.office #qq

sudo pacman -S google-chrome #谷歌浏览器

sudo pacman -S netease-cloud-music #网易云

sudo pacman -S fcitx-im
sudo pacman -S fcitx-configtool #输入法配置器

sudo pacman -S ttf-roboto noto-fonts ttf-dejavu wqy-bitmapfont wqy-microhei wqy-microhei-lite wqy-zenhei noto-fonts-cjk adobe-source-han-sans-cn-fonts adobe-source-han-serif-cn-fonts # 字体
```



#### 修改浏览器快捷键

```shell
vim ~/.i3/config
#修改为如下
bindsym $mod+F2 exec --no-startuo-id 'google-chrome-stable' #定义f2快捷键为谷歌浏览器
```



#### 扩展屏幕

```shell
sudo pacman -S lxrandr
```



#### 右上角时钟乱码

```shell
sudo vim /usr/share/conky/conky_maia
#修改 font中的字体为 WenQuanYi Micro Hei
```



#### 壁纸

```shell
sudo pacman -S feh
feh --bg-center ~/Pictures/1.jpg #设置壁纸
vim ~/.i3/config
exec feh --bg-center ~/Pictures/1.jpg  #开机自动生效
```



#### 配置输入法

```shell
#<mod> + d唤醒搜索,搜索fcitx-configtool
#自行选择

vim ~/.i3/config
exec fcitx #开机自启
```
