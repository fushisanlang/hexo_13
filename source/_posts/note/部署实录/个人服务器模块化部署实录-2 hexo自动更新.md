---
title: 个人服务器模块化部署实录-2 hexo自动更新
tags:
  - 部署实录
  - docker
  - hexo
categories:
  - note
abbrlink: 8880cf81
date: 2022-01-13 09:10:00
---
## 背景
之前，将大部分服务调整为 `docker` 模块化部署了。
但是之前操作时忘了自己的博客。
我的博客使用的是 `hexo` 框架。每次更新博客的流程大致如下：
1. 在本地编辑md文件
2. 将文件上传到git
3. 登陆服务器，进行拉取
4. 使用hexo g命令生成静态网站
5. 将静态网站内容放入nginx对应目录进行发布
6. 如果是新发布的文章，hexo会对文章生成唯一id。所以需要在hexo g之后重新将md文件同步到git
7. 本地拉取最新的git，将有id的md文件保存到本地

虽然已经将3～6步写成了脚本，可以直接使用。但是每次免不了要登陆服务器。费时费力不说，有时候并不方便登陆服务器，所以打算进行一个优化。

第二点是因为对 `hexo` 博客做了一定的主题调整，下载了主题，调整了许多配置，也安装了一些插件。
即使自己留了记录，但是如果有一天真的突发情况，想恢复其实也浪费时间。
综合以上两点，决定将` hexo` 封装成 `docker` 镜像，这样容易迁移。
同时利用 `git` 的 `webhook` 功能，进行自动更新。

## 想法思路
整体实现过程中，想了许多思路，有些不成熟，只是拍脑门想出来的，都列举到下边了。

*方案1:*
*通过api容器控制博客的docker容器，进入容器中做git和hexo g。再将生成的文件转移的nginx路径。*
*此方案使用时，博客的容器一直启动，需要不停进入内部做操作。* 

*这个方案问题在于，不符合docker的使用逻辑。*
*容器一旦生成之后，我自己理解，不应该对内部做太多变动。*
*而且一旦生成了静态文件之后，在下次生成静态文件之前，这个docker容器是无用的，浪费资源。*


*方案2:*
*通过api容器控制宿主机。*
*每次变动之后，一次性创建一个hexo容器，通过git clone，hexo g等命令输出一个静态路径。然后将hexo容器删除。*

*这种方案好处就是少一个持续运行的容器。*
*但是经过仔细考虑之后，发现是行不通的。需要一个编排工具来进行容器的创建。这个动作api容器是无法实现的，或者说api容器需要比hexo容器更高一级才可以。个人觉得是类似k8s的接口了。暂时其实没有必要引入这么大的架构。*

上述两个方案想法都不错，但是问题在于很难通过容器去控制宿主机，这样是不安全的。

问题变成了如何做一个中控容器来控制其他容器。
如果不引入 `k8s` 之类的编排工具其实很难实现。所以只能将方案进行调整。



最终方案：
每个 `hexo` 容器加一个 `api` 功能用作接受通知。
在收到通知后，进行 `hexo` 的部署动作，以及静态文件的切换。

于是问题拆分成了如下三点：
1. 创建一个hexo镜像
2. 给hexo容器添加一个api接口用于接受通知
3. 让hexo容器可以执行博客的更新操作

## 创建hexo基础镜像
`hexo` 是基于 `node.js` 语言的框架，所以最终镜像应该是基于 `node.js` 基础镜像的。
`node.js` 一共有三个主流镜像，这里因为没用到 `c/c++` 相关，所以直接选用了基于 `alpine` 的镜像。
由于之前服务器 `node` 版本是14，这里也使用了14版本。
具体 `Dockerfile` 如下：
```Dockerfile
FROM node:14-alpine
RUN mkdir /blogs
WORKDIR /blogs
RUN mkdir /export
RUN npm install express child_process  hexo --registry=https://registry.npm.taobao.org
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories 
RUN apk add git
RUN mkdir myblog
#api文件
COPY index.js .  
#脚本文件
COPY node.sh .   
RUN chmod +x node.sh
EXPOSE 8081
CMD ["node" , "index.js"]
```
基础镜像主要做了如下操作：
1. 安装`hexo` ，`express` ，`child_process`
2. 创建后续会用到的两个目录
3. 传入接口文件和操作脚本文件 *具体文件内容后续会有介绍*
4. 启动接口文件

至此，`创建一个hexo镜像`完毕。


## api接口建立
因为基础镜像使用了 `node.js` 镜像，为了使镜像尽量简化，所以接口最好也是用 `node.js` 进行开发。
这里使用了 `express` 进行 `api` 开发。
由于功能相对简单，所以只需要一个 `js` 文件即可。
具体 `js` 如下：
```js
#!/usr/bin/env node
var express = require('express');
var app = express();

app.post('/updateandpush', function (req, res) { //这里定义一个路由
    var child = require('child_process'); 
    child.exec('/bin/sh /blogs/node.sh', function(err, sto) { //这里使用了child_process来运行脚本。具体脚本内容后边会说
})
    res.send('Hello World'); //返回。如果没有这返回，所有访问都会超时。这样对后续动作的判断不友好。
})
 
var server = app.listen(8081, function () { //这里是启动服务。因为是通过docker启动，端口随意，后续会映射成主机端口

        console.log("start")
})
```

通过上述代码，我们创建了一个 `web` 服务。这个服务有一个 `/updateandpush` 路由。
当我们访问这个路由的时候，服务会执行 `/blogs/node.sh` 脚本。
到此，`给hexo容器添加一个api接口用于接受通知` 解决。

## 博客更新脚本
因为在改造之前，使用了 `shell` 开发了一个小脚本。用于博客内容的拉取，输出等。
在此次改造过程中。本来想依旧是用 `node.js` 进行脚本改造。
但是在 `hexo` 的 `hexo g` 命令改造时，没找到合适的方法。
这里也是因为个人水平有限，没学过 `js` 和 `node` 相关知识，后续可能会进行优化。
所以最终还是沿用了shell开发脚本。
脚本内容如下：
```shell
#!/bin/bash
cd /blogs/myblog 
echo ${gitUrl}
git remote set-url origin ${gitUrl} 
git config --global user.email ${gitEmail}
git config --global user.name ${gitName}
rm -fr public
git pull
./node_modules/hexo/bin/hexo g
git add source
git commit -m "auto push by builder "
git push
rm -rf /export/*
mv public/*  /export
```
到此，`让hexo容器可以执行博客的更新操作`完成。

## 生成容器并配置webhook
经过上述三个步骤，已经将准备工作完成，这一步就是要通过镜像生成一个容器，并通过在 `git` 上配置 `webhook` 来实现最终目的。

### 构建镜像
```shell
mkdir -p /dockerfiles/blog-base #创建一个路径来构建镜像
cd /dockerfiles/blog-base
vim Dockerfile #写入文件
vim index.js #写入文件
vim node.sh #写入文件
docker build -t 'hexo:base' . #构建镜像
```
### 生成容器
```shell
gitName=xxx #git账号
gitPass=xxx #git密码
gitEmail=xxx #git邮箱
gitUrl=git.fushisanlang.cn/xxx/xxx.git #git地址
gitUrlWithName=https://${gitName}:${gitPass}@${gitUrl} #带密码的git地址。这里因为镜像默认没有ssh，所以使用了http访问，通过账号密码登陆的方式。如果觉得不安全可以尝试安装openssh后使用ssh来获取代码
name=blog-blog #容器名
port=40000 #容器端口
blogdir=/blog/ #本地blog目录，这里容器采用挂载的方式，没有直接将整个博客放入容器，可以根据个人想法调整
nginxdir=/usr/local/nginx/html/ #nginx的静态地址

docker run -d -e gitName=${gitName} -e gitEmail=${gitEmail}  -e gitUrl=${gitUrlWithName}  --name ${name} -p ${port}:8081 -v ${blogdir}:/blogs/myblog -v ${nginxdir}:/export  hexo:base

#这里这么用是为了方便注释，实际使用时一条命令就搞定了，没必要弄这么多变量。
```

### 配置nginx及git webhook
至此，已经可以达到访问 `xxx:40000/updateandpush` ，就可以自动更新博客的功能。
但是由于实际使用中，不可能将这个地址暴露在外，这样是不安全的。
另外由于我有多个 `hexo` 博客，需要区分不同博客。
我选择的方式是通过 `nginx` 代理这些容器的端口，并且限制来源ip。
这里值得注意的是，我使用的是自建的 `git` ，所以来源ip是固定的。如果使用 `gitee` ，`github` 等，来源ip需要自己注意。
我做的 `nginx` 配置如下：
```
    location  /1/ { #第1个博客
        allow 127.0.0.1;
        deny all;
        proxy_pass http://127.0.0.1:40000/updateandpush; #40000是第1个博客对应容器的端口
        include /usr/local/nginx/conf/proxy.conf ;
    }
    location  /2/ {#第2个博客
        allow 127.0.0.1;
        deny all;
        proxy_pass http://127.0.0.1:40001/updateandpush;#40001是第2个博客对应容器的端口
        include /usr/local/nginx/conf/proxy.conf ;
    }
```
在使用中，只需要访问 `xxx/1` ，就可以访问到 `http://127.0.0.1:40000/updateandpush` 以此更新第一个博客。同理，就可以通过后缀区分多个博客的更新地址。

最后，登录到 `git` 的仓库配置，在 `webhook` 里配置相应的访问地址，并且选择需要监控的事件，就能达到自动向 `xxx/1` 推送请求的效果。

### 最终效果
在本地书写一篇 `md` 博客，同步到 `git` 中。
此时 `git` 接收到 `push` 请求，会向 `webhook` 地址发送一个 `POST` 请求。
`nginx` 接收到请求之后，将请求代理到对应的 `docker` 容器。
容器中， `index.js` 接收到请求，执行 `node.sh` 脚本。
博客更新。

### 可改进点
这只是1.0版本，单单达到了可用。还有许多可以改进的地方。
- [ ] 更新情况通知
- [ ] webhook信息的使用
- [ ] 异常后的回滚处理
- [ ] 更新方式改造
- [ ] 多次推送如果间隔过短，容器会多次发布。这样生成的文件可能会是混乱的，需要一个文件锁来保证文件的一致性。
- [ ] so on