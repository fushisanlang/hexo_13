---
title: Centos 7 安装 elasticsearch 8 及添加密码认证
date: 2022-3-15
tags:
  - Elasticsearch
  - xpack
  - cerebro
  - elk
categories:
  - note
abbrlink: '24548045'
---


# Centos 7 安装 elasticsearch 8 及添加密码认证

## 安装
*可以使用yum安装或使用压缩包直接启动。为了方便启停，我这里使用了yum安装*

```shell
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

vim /etc/yum.repos.d/es.repo #内容如下
cat /etc/yum.repos.d/es.repo
[elasticsearch]
name=Elasticsearch repository for 8.x packages
baseurl=https://artifacts.elastic.co/packages/8.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=0
autorefresh=1
type=rpm-md

sudo yum install --enablerepo=elasticsearch elasticsearch 
```


## 调整系统配置
可以参考之前 elasticsearch 7 的配置调整。
[Elasticsearch安装配置](https://www.fushisanlang.cn/article/b0625b51.html)

## 配置
```shell
mkdir -p /data/es/data /data/es/log /data/es/ssl  #存放日志，数据及证书的路径
chown elasticsearch:elasticsearch /data/es -R


vim /etc/elasticsearch/elasticsearch.yml #内容如下
cat /etc/elasticsearch/elasticsearch.yml

cluster.name: fushisanlang
node.name: node-1
path.data: /data/es/data
path.logs: /data/es/log
network.host: 0.0.0.0
http.port: 51000
discovery.seed_hosts: [127.0.0.1]
cluster.initial_master_nodes: ["node-1"]
xpack.security.enabled: true
xpack.license.self_generated.type: basic
xpack.security.transport.ssl.enabled: true
xpack.security.transport.ssl.verification_mode: certificate
xpack.security.transport.ssl.client_authentication: required
xpack.security.transport.ssl.keystore.path: /etc/elasticsearch/ssl/elastic-certificates.p12
xpack.security.transport.ssl.truststore.path: /etc/elasticsearch/ssl/elastic-certificates.p12

echo '-Xmx128M' >>  /etc/elasticsearch/jvm.options
echo '-Xms128M' >>  /etc/elasticsearch/jvm.options
```

## 创建证书
```shell
/usr/share/elasticsearch/bin/elasticsearch-certutil ca #密码可以不输入
/usr/share/elasticsearch/bin/elasticsearch-certutil cert --ca elastic-stack-ca.p12 #密码可以不输入

#此时会在	/usr/share/elasticsearch 生成两个证书
#因为是采用yum安装的，需要将两个证书放到 /etc/elasticsearch/ 下。直接通过zip包启动的情况不确定是否需要，可以根据日志调整

cp /usr/share/elasticsearch/elastic-certificates.p12  /usr/share/elasticsearch/elastic-stack-ca.p12 /data/es/ssl
ln -s /data/es/ssl/ /etc/elasticsearch/ssl

chown elasticsearch:elasticsearch /data/es -R

```

## 启动服务

```shell
systemctl start elasticsearch.service
```

## 创建用户

```shell
/usr/share/elasticsearch/bin/elasticsearch-setup-passwords auto #自动生成

/usr/share/elasticsearch/bin/elasticsearch-setup-passwords interactive #手动输入密码
```

## cerebro 插件安装

上述操作之后，es就已经可以使用了。日常运维以及查数据的时候，可以使用一些插件来简化操作。比如使用kibana，我这里找到了一个cerebro插件。
[cerebro](https://github.com/lmenezes/cerebro)

我这里因为服务器上没有合适的java环境，选择了使用docker安装。
```shell
docker pull lmenezes/cerebro
docker run -d -p 9000:9000  --restart=unless-stopped --name cerebro lmenezes/cerebro

#之后访问9000端口即可
```