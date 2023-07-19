---
title: WSl创建golang-unix开发环境
date: 2017-3-23
updated: 2017-3-24
tags:
  - code
  - wsl
  - vimgo
categories:
  - note
abbrlink: 20d06290
---

# WSl创建golang-unix开发环境

*未作说明均为普通用户操作。为了美观不在命令中添加命令提示符*

* ### 环境介绍

|环境|版本|
|:-:|:-:|
|主机环境|win10专业版|
|wsl环境|ubuntu 20.04lts|



* ### 安装wsl 

开启wsl服务后，在微软商店搜索wsl，下载相应版本即可



* ### 安装Windows Terminal

同样在微软商店搜索安装。因为wsl自带的terminal环境过于简陋，使用微软推出的terminal环境。



* ### 基础环境配置

  * 配置root密码（可不做）

    ```shell
    sudo passwd 
    #根据提示设置密码即可
    ```

  * 更改apt源

    ``` shell
    sudo cp /etc/apt/sources.list /etc/apt/sources.list_bak
    sudo > /etc/apt/sources.list
    sudo echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse" >> /etc/apt/sources.list
    sudo echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse" >> /etc/apt/sources.list
    sudo echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse" >> /etc/apt/sources.list
    sudo echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-security main restricted universe multiverse" >> /etc/apt/sources.list
    
    sudo apt-get update
    sudo apt-get upgrade
    ```

  * 安装zsh

    ```shell
    sudo apt-get install zsh
    #根据提示配置即可
    chsh -s $(which zsh)
    ```

  * 安装ohmyzsh

    ```shell
    wget 'https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh'  -O ~/1.sh
    sh ~/1.sh
    #这一步可以直接类似 wget sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"的命令进行操作。但是实验多次发现都是访问异常。为了操作方便，直接下载脚本到本地执行
    ```

    

  * 配置zsh

    ```shell
    vim ~/.zshrc #修改环境
    	ZSH_THEME="ys" #这个是主题标签，可以根据喜好设置主题，具体主题名称可以百度
    	
    git config --global oh-my-zsh.hide-status 1 
    #因为ys主题包含git插件，在进行文件操作时，会对操作进行git分析。导致命令执行卡顿。
    #通过设置全局变量，取消文件操作时的git信息
    #后边会有对git项目如何配置git信息
    
    #再一点就是，系统的环境变量文件 /etc/profile、 ~/.bash_profile等，在zsh环境默认是不会加载的。
    #相关环境变量的配置，可以直接配置到~/.zshrc中。如果不方便单独配置，可以在~/.zshrc中，添加source /etc/profile（相关文件自行替换文件名）即可。
    ```





* ### go开发环境配置

  *目前可以进行go语法检查，其他功能未配置，下文提到的文件可以联系313346216@qq.com*

  * 安装golang环境

    ```shell
    wget https://dl.google.com/go/go1.14.4.linux-amd64.tar.gz  #当前官网最新版本
    sudo tar xf go1.14.4.linux-amd64.tar.gz -C /usr/bin
    
    echo export GOPATH=\"~/src/go/\" >> ~/.zshrc
    echo export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin>> ~/.zshrc
    #配置go环境和gopath
    
    source ~/.zshrc
    ```

  * 安装Vundle.vim

    ```shell
    #具体步骤自行百度。
    #本人使用下载好的目录代替
    ```

  * 安装vim-go

    ```shell
    #具体步骤自行百度。
    #本人使用下载好的目录代替
    ```

  * 安装相应go库

    ```shell
    #具体步骤自行百度。
    #本人使用下载好的目录代替
    ```

  * 配置vim

    ```shell
    #编辑~/vimrc,本人使用配置过的文件代替
    vim
    	:PluginInstall
    	#安装vim插件
    ```

    

* 具体项目配置

  * git目录配置

    ```shell
    #因为上文设置了git全局不检查文件信息，对于需要检查文件信息的路径，可以使用下列命令进行配置
    cd ${项目路径}
    git config --add oh-my-zsh.hide-dirty 0
    git config --add oh-my-zsh.hide-status 0
    ```

    

  * 一些其他小技巧

    ```shell
    #因为配置这套环境主要是为了做go的小demo开发，为了方便开发操作，做了一些命令的别名
    vim ~/.zshrc
    	alias kun="cd /home/fu13/src/go/src/kun && git pull" #单独命令进到项目路径并拉取代码，用来在每次访问环境时候快速进入开发状态
    	alias ls ="ls -la" #为了应付隐藏文件过多的问题
    ```

    



