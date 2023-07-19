---
title: ngrok
date: 2018-3-21
updated: 2018-3-22
tags:
  - ngrok
  - 内网穿透
categories:
  - note
abbrlink: 29a1820d
---

### 软件介绍

ngrok是一个内网穿透的解决方案,它使得你本地的服务器可以被局域网外的公网访问到
ngork有服务端和客户端，服务端运行在公网服务器，客户端运行在本地服务器
ngrok服务端会建立http和https服务，默认端口80/443，以及供ngrok客户端连接的服务，默认端口4443

<!--more-->
### 工作流程

访问端输入域名->DNS->ngrok服务端->请求映射到ngrok客户端->客户端返回响应到ngrok服务端->ngrok服务端返回响应到访问端

### 本文环境
centos7 64位 

### 准备工作
一台公网服务器
一个域名，顶级或二级均可
关于域名：我们声明两个概念：一个是基础域名，可以是顶级或者二级，它用来为ngrok服务端本身提供外部访问（ngrok客户端连接用）。二就是基于基础域名的二级或者三级域名，它用来映射到你的本地服务器，我称它为映射域名。它可以设置多个，这取决于你的需要。例如 fushisanlang.cn 和 ngrok.fushisanlang.cn / ngrok2.fushisanlang.cn，每个映射域名对应一个ngrok客户端

假设你的域名是 fushisanlang.cn (全文皆使用此假设)

如果你需要使用顶级域名作为基础域名，那么请将 fushisanlang.cn 泛解析到服务器ip，然后将你需要使用的二级域名通过A记录解析到服务器ip,例如 ngrok.fushisanlang.cn

如果你需要使用二级域名，那么先将你的二级域名 xxx.fushisanlang.cn 通过A记录解析到服务器域名。然后将三级域名（比如 test.xxx）通过CNAME的方式解析到 xxx.fushisanlang.cn，这次 xxx.fushisanlang.cn 便成为了客户端与服务端的连接域名，test.xxx.fushisanlang.cn 则是映射域名

下面的教程我们使用 fushisanlang.cn 作为基础域名演示

### 操作步骤

1. 安装git和go以及其它依赖
```shell
yum install gcc mercurial git bzr subversion golang golang-pkg-windows-amd64 golang-pkg-windows-386 -y
```

2. 下载源码 （项目早已停止更新，源码完全固定）
```shell
git clone https://github.com/inconshreveable/ngrok.git
#完成后会在当前目录生成ngrok目录
```

3. 生成证书（默认的证书是 ngrok.com，我们需要改成 fushisanlang.cn）
```shell
# 生成
cd ngrok  
mkdir cert 
cd cert
export NGROK_DOMAIN="fushisanlang.cn"
openssl genrsa -out rootCA.key 2048
openssl req -x509 -new -nodes -key rootCA.key -subj "/CN=$NGROK_DOMAIN" -days 5000 -out rootCA.pem
openssl genrsa -out device.key 2048
openssl req -new -key device.key -subj "/CN=$NGROK_DOMAIN" -out device.csr
openssl x509 -req -in device.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out device.crt -days 5000

# 替换(提示overwrite输入y)
cp rootCA.pem ../assets/client/tls/ngrokroot.crt
cp device.crt ../assets/server/tls/snakeoil.crt
cp device.key ../assets/server/tls/snakeoil.key
```

4. 生成服务端与客户端

```shell
cd ..
#以下命令按需生成

# <!--linux服务端/客户端-->
GOOS=linux GOARCH=386 make release-server (32位)
GOOS=linux GOARCH=amd64 make release-server（64位）

GOOS=linux GOARCH=386 make release-client (32位)
GOOS=linux GOARCH=amd64 make release-client（64位）

#<!--Mac OS服务端/客户端-->
GOOS=darwin GOARCH=386 make release-server
GOOS=darwin GOARCH=amd64 make release-server

GOOS=darwin GOARCH=386 make release-client
GOOS=darwin GOARCH=amd64 make release-client


#<!--windows服务端/客户端-->
GOOS=windows GOARCH=386 make release-server
GOOS=windows GOARCH=amd64 make release-server

GOOS=windows GOARCH=386 make release-client
GOOS=windows GOARCH=amd64 make release-client

#所有程序都将生成在bin目录中，不同平台将建立不同的子目录

```



### 启动服务端
```shell
./bin/ngrokd -domain="fushisanlang.cn"

#其它配置：
-httpAddr=":80" http服务的访问端口 默认80
-httpsAddr=":443" https服务的访问端口 默认443
-tunnelAddr=":4443" 客户端连接服务端的端口 默认4443
#以上端口，如若与系统其他服务有冲突，开启服务时请自行配置其他端口，同时记得配置防火墙
```
### 客户端配置与连接

```shell
#新建配置文件ngrok.cfg
#<!--配置服务端连接地址，也就是基础域名。端口则与服务端-tunnelAddr配置相同-->

server_addr: "fushisanlang.cn:4443"  
trust_host_root_certs: false

#运行客户端

ngrok -config=ngrok.cfg -subdomain ngrok 80 

-subdomain用来指定域名的前缀（也就是映射域名的前缀），如上设置ngrok，当访问ngrok.fushisanlang.cn时，ngrok服务端接收到请求后，便会将客户端http相应返回给访问端。80用来指定本地http服务的端口
```

### 验证
浏览器输入ngrok.fushisanlang.cn，查看返回结果

### 改进点
关于证书，可以尝试使用域名商提供的认证证书，后续会进行相应尝试。
