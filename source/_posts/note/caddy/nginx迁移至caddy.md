---
title: nginx迁移至caddy
date: 2024-04-17

tags:
  - nginx
  - caddy
  - docker
categories:
  - note

---

## 背景说明
之前一直使用 `nginx 1.12.1`，这个版本来自于入行的第一家公司，因为当时用了一些软WAF规则，所以选择了这版nginx一直没升级。   
后来因为request body size的问题，我一度想更换掉nginx。但是因为只有nginx用的最熟，所以还是更新了版本，没有换别的软件。   
然后2024年开始，阿里云的免费证书时间从一年变成三个月后，连续两次证书过期，让我坚定了更换caddy的决心。   
期间也看过类似certbot的功能，但是我古老的centos7系统竟然不能安装最新版certbot，变形导致了我更新整个操作系统。   
所以在新操作系统安装之后，我直接把nginx换成了caddy。

## 特性介绍
caddy是个比较年轻的代理服务器，他的功能和拓展性在现在这个时间节点应该是不如nginx的，但是他有如下几个特性支持我使用它：
1. 可以自动申请https证书   
2. 基本功能的配置简单   
我基本算是熟练使用nginx了，但是对于个人服务器是使用nginx还是有些难受，因为他太麻烦了。caddy完美解决了我的痛点。   
至于性能反而是我不需要在意的，对于个人站点来说很难达到任何一种代理服务器的性能上限。

## 部署过程
以前就考虑使用docker部署nginx，但是因为种种原因放弃了。   
这次因为是重新部署，所以我直接选择了docker方式。   
```shell
mkdir -p /data/docker-compose/caddy
mkdir -p /data/caddy_docker

docker network create net-server
cd /data/docker-compose/caddy
vim  docker-compose.yaml

cd /data/caddy_docker/
vim Caddyfile

cd /data/docker-compose/caddy
docker-compose up -d
```
整个部署过程很轻松。第一次启动的时候会去申请https证书。


---

附件1： docker-compose.yaml
```yaml
version: '3'
services:
  caddy:
    image: caddy:latest
    restart: always
    container_name: caddy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /data/caddy_docker/Caddyfile:/etc/caddy/Caddyfile #配置文件
      - /data/caddy_docker/html:/data/html  #静态文件
      - /data/caddy_docker/logs:/data/logs  #日志文件
      - /data/caddy_docker/data:/data/caddy #证书文件
      - /etc/localtime:/etc/localtime:ro    #时区
    networks:
      - net-server
networks:
  net-server:
    external: true #使用一个预置的network
```

附件2： Caddyfile
```
www.fushisanlang.cn {                         #域名
    reverse_proxy http://blog-40000           #代理地址
    log {                                     #日志配置
        output file /data/logs/blog/access.log {
            roll_size 10MiB
            roll_keep 5
            roll_keep_for 720h
        }
        format json
    }
}
download.fushisanlang.cn {                   #域名
    root * /data/html/download				 #root
    file_server
    encode gzip
    header / {
        X-Frame-Options SAMEORIGIN
    }
    log {
        output file /data/logs/download/access.log {
            roll_size 10MiB
            roll_keep 5
            roll_keep_for 720h
        }
        format json
    }
}
```
