---
title: nginx+lua学习
date: 2026-06-15
tags:
  - nginx
  - lua
  - openresty
categories:
  - note
---

nginx + lua（OpenResty）学习笔记，涵盖基础命令、平滑升级、配置文件等。

<!--more-->

## nginx 命令和信号控制

```bash
nginx -s stop      # 快速关闭，不管有没有正在处理的请求
nginx -s quit      # 优雅关闭，完成已接受的连接请求后才退出
nginx -c /path/nginx.conf   # 指定配置文件启动
nginx -s reload    # 重启
nginx -s reopen    # 重新打开日志
nginx -t           # 检查配置文件是否正确

kill -INT pid      # 快速关闭
kill -HUP pid      # 重启
```

## nginx 平滑升级

```bash
# 1. 下载高版本，解压缩，执行
./configure
make

# 2. 备份旧版本
cd objs
cp nginx nginx.old
cp -rfp objs/nginx /usr/local/nginx/sbin/

nginx -t
ps -ef | grep nginx

# 3. 发送 USR2 信号平滑升级
kill -USR2 `cat /usr/local/nginx/logs/nginx.pid`
# nginx 会将 nginx.pid 重命名为 nginx.pid.oldbin，用新的可执行文件启动新进程

# 4. 关闭旧的工作进程（保留主进程以便回滚）
kill -WINCH 旧的主进程号
```

## 配置文件优化

```bash
ulimit -n   # 查看 Linux 最多同时打开的文件句柄数

# nginx.conf 中配置
worker_rlimit_nofile 65535;   # 配置最大文件句柄数

# 四核 CPU 配置
worker_processes 4;
worker_cpu_affinity 0001 0010 0100 1000;
```

## 日志切割

可配合 crontab 使用 `nginx -s reopen` 或通过信号控制实现日志轮转。

## OpenResty 安装

OpenResty 是 nginx + lua 的完整发行版，预编译了 lua 相关模块，适合做网关、WAF、API 网关等。

## nginx 内部变量

常用变量：

- `$request_uri`：原始请求 URI
- `$uri`：当前请求 URI（不含参数）
- `$args`：查询参数
- `$host`：请求主机名
- `$remote_addr`：客户端真实 IP
- `$http_x_forwarded_for`：代理转发时的客户端 IP

## redis 模块 demo（lua）

```lua
local redis = require "resty.redis"
local red = redis:new()
red:set_timeout(1000)
local ok, err = red:connect("127.0.0.1", 6379)
if not ok then
    ngx.say("failed to connect: ", err)
    return
end
ok, err = red:get("key")
if ok then
    ngx.say("value: ", ok)
end
red:close()
```

## redis 连接池

```lua
local redis = require "resty.redis"
local red = redis:new()
red:set_timeout(1000)
red:connect("127.0.0.1", 6379)
-- 使用后放回连接池
red:set_keepalive(1000, 100)
```
