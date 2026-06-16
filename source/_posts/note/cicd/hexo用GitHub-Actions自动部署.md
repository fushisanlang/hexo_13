---
title: hexo 用 GitHub Actions 自动部署
date: 2026-06-16 11:20:00
tags:
  - hexo
  - github-actions
  - docker
  - 部署实录
categories:
  - note
---

## 背景

旧的 hexo 部署方案是 2022 年那套:本地 git push → 服务器 git webhook 触发脚本 → 服务器上 `docker run` hexo 镜像跑 `hexo g` → 静态文件塞进 nginx 容器。

2GB 内存的阿里云小破服务器,`hexo g` 一直 OOM。`swap` 加了、`--memory=500m`/`--memory=1g` 都试过,要么 kill 要么慢得离谱。9 个月前最后一次成功部署,之后就再没更新过。

## 思路

跑不动就别跑。把 `hexo g` 拆出去。

- **GitHub Actions runner** 7GB 内存免费用,跑 `hexo g` 轻轻松松
- 服务器只负责把 `public/` 接到 nginx 上,不再跑构建

架构:
```
本地 git push
  → GitHub Actions(ubuntu-latest)
      ├─ setup node 21.7.3 + cache npm
      ├─ npm install(npmmirror 源)
      ├─ hexo g 生成 public/
      ├─ ssh 到服务器,准备 /tmp/blog-staging
      ├─ scp public/ 到 /tmp/blog-staging/(不碰 server 配置目录)
      └─ ssh 到服务器:
          ├─ cp -r /tmp/blog-staging/public /data/docker-compose/blog/public
          ├─ rm -rf /tmp/blog-staging
          ├─ cd /data/docker-compose/blog/(project name = blog)
          ├─ sed 改 docker-compose.yaml 里的 image tag
          ├─ docker build -t blog:v$TS -f Dockerfile.final .
          ├─ docker stop + rm blog-40000
          ├─ docker-compose up -d
          └─ 清理旧 blog 镜像
```

## Dockerfile.final

```dockerfile
FROM docker.m.daocloud.io/library/nginx:alpine
COPY public/ /usr/share/nginx/html/
COPY ads.txt /usr/share/nginx/html/ads.txt
```

daocloud mirror 是关键。直接 `nginx:alpine` 在国内服务器上拉 `docker.io` 超时(`dial tcp 162.125.17.131:443: i/o timeout`),`registry.cn-hangzhou.aliyuncs.com/library/nginx:alpine` 又没权限,daocloud 反而通。

## 踩过的坑(按踩到顺序)

### 1. `registry.npm.taobao.org` 证书过期
`yarn` 包 `postinstall` 拉旧淘宝源,cert expired。删 `yarn` 依赖,registry 改新淘宝 `registry.npmmirror.com`。

### 2. `package-lock.json` 硬编码国内源
lock 文件里 `registry.nlark.com` / `registry.npmmirror.com` 一堆,runner 在国外直接 `ENOTFOUND`。最干脆是**直接删 `package-lock.json`**,让 workflow 每次重新算,加 `actions/cache` 缓存 `node_modules/`。

### 3. `scp-action` 的 `rm: true` 是坑
`appleboy/scp-action@v0.0.6` 加 `rm: true` 不只清 target 目录的内容,会把 target 的**整个父目录**一起清空。`public/` 传到 `/data/docker-compose/blog/public/` 没问题,顺带把 `Dockerfile.final` / `docker-compose.yaml` / `ads.txt` 全冲掉了。
改成 v0.1.7 不带 `rm`,scp 默认 `rm: false`,只 mkdir + untar,不会动其他文件。

### 4. scp 不动 server 配置目录 = 安全
进一步把 scp 拆两步:先 scp 到 `/tmp/blog-staging/` 临时目录,再 ssh `cp -r` 到 `/data/docker-compose/blog/public/`。这样 server 配置目录永远不被 workflow 写,只 `cp` public 子目录进去。

### 5. `docker-compose down` 不到手动 run 的容器
测试时手贱 `docker run --name blog-40000` 启动过,容器没 `Project=blog` label。后来 workflow `docker-compose down` 是 no-op,然后 `docker-compose up` 因为同名 container 冲突失败。
**修法**:`docker-compose up` 之前显式 `docker stop blog-40000 && docker rm -f blog-40000`,不依赖 compose 自己找。

### 6. `docker-compose` v1 / v2 行为差异
server 上 `docker-compose` v1.29.2(Python)和 `docker compose` v2.29.7(Go plugin)并存。
- v1 在 yaml 里 image tag 改了之后 down 不到 running container
- v2 用 cwd basename 当 project name,`/tmp/blog-staging` → `project=blog-staging`,跟之前启动时的 `project=blog` 不匹配
最后是 build 改回 `/data/docker-compose/blog/` 里跑,project 自动 = `blog`,`docker-compose down/up` 才认得旧容器。

## 现在的 workflow `.github/workflows/deploy.yml`

触发:`push master` 或 `workflow_dispatch`
- 7GB runner + 15 分钟 timeout
- `setup-node@v4` 锁 21.7.3
- `actions/cache@v4` 缓存 `node_modules/`,key = `runner.os-node-{hashFiles('package.json')}`
- `npm install --registry=https://registry.npmmirror.com`(cache miss 才装)
- `hexo g`
- 4 个 ssh/scp 步骤见上面的架构图

## 凭据(GitHub Secrets)

- `SERVER_HOST` `fushisanlang.cn`
- `SERVER_USER` `root`
- `SERVER_PORT` `9871`
- `SSH_KEY` 私钥全文(PEM)

`scp-action` 跟 `ssh-action` 共用 `SSH_KEY`。

## GitHub 私有仓库免费额度

2000 分钟/月(按账号下所有私有 repo 共用,不是按仓库)。hexo 跑一次 1 分钟左右,绑死仓库都不用担心爆。公共仓库无限。

## 教训

1. **scp 的 `rm` 选项看清楚**:v0.0.6 的 `rm: true` 跟我想的"只删 source 同名目录"不一样,父目录其他文件也会没。永远用临时目录 + cp,不要直接 scp 到配置目录。
2. **server 上的容器不一定都是 compose 启动的**:被谁 `docker run` 起来都不奇怪,`docker-compose down` 找不到别怪它。在 up 之前显式 `stop+rm` 兜底。
3. **国内服务器拉 docker.io 必超时**:build 之前先想好 `FROM` 写哪个 mirror,daocloud / 阿里云 / 腾讯云容器镜像,任挑一个。
4. **server 上 `docker-compose` v1 跟 `docker compose` v2 行为不一样**:看 yaml 不一样时,先确认 server 上跑的是哪个版本。
