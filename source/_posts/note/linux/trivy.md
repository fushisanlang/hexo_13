---
title: trivy
date: 2023-7-10
tags:
  - trivy
  - docker
  - harbor
categories:
  - note
abbrlink: 1cfc3e42
---

# trivy 扫描工具踩坑记录

## 介绍
`trivy` 是一个镜像扫描工具，用于扫描 `docker image` 是否有漏洞。现在最新版本不仅支持 `image` 扫描，也有了其他功能。   


## 基础使用
```shell 
# 扫描镜像，并按照模板内容输出json格式
trivy image --exit-code 0  --server $TRIVY_SERVER --username $HARBOR_USER --password $HARBOR_PASS --format template --template "@/contrib/gitlab.tpl" --output "$TRIVY_CACHE_DIR/dotnet-scanning-report.json" $IMAGE_NAME_DOTNET:$IMAGE_VERSION    

# 扫描镜像，输出内容到控制台
trivy image --exit-code 0  --cache-dir /db/cache --skip-db-update --username $HARBOR_USER --password $HARBOR_PASS $IMAGE_NAME_DOTNET:$IMAGE_VERSION

# 扫描镜像，只扫描级别为CRITICAL的漏洞。如果有异常，则异常退出，用于后续操作前的判定
trivy image --exit-code 1  --cache-dir /db/cache --skip-db-update --username $HARBOR_USER --password $HARBOR_PASS --severity CRITICAL $IMAGE_NAME_DOTNET:$IMAGE_VERSION

# 以server模式运行，端口为 0.0.0.0:10000
trivy --cache-dir /data/cache  server  --listen 0.0.0.0:10000
```


其他的用法在[官方文档](https://aquasecurity.github.io/trivy/v0.43/)中有比较详细的记载，我这里就不摘抄了，着重记录一下踩坑后的记录

## 踩坑记录
1. 基于 `docker` 的 `trivy` 使用时，如何保存数据库，而不是每次重新下载   
最初使用时，按照教程，直接通过 `docker run  aquasec/trivy image nginx` 这种方式，他需要下载一个`内置数据库`。   
按照文档所说（文档是英文，有点理解不到位），我尝试通过挂载容器中 `/root/.trivy` 路径来保留`缓存`。但是发现并没生效。   
后来发现实际的`默认数据库路径`在 `/tmp` 下，为了防止每次执行都重新下载，我自己构建了一个 `trivy:with_db` 镜像。   
在这个镜像中，通过 `docker run -v  /tmp/cache:/data/cache aquasec/trivy --cache-dir /data/cache image nginx` 自定义了一个 `cache` 路径，用于存储`数据库`。   
但是在使用中又发现，不止有一个`基础库`，还有一个 `java` 相关的库，所以这里又重新构建了一次镜像。   
如果后续有相同需求，第一次打包镜像的时候就要下载好两个`基础库`。

2. 自己创建一个 `db` 镜像   
官方文档里边有些，可以指定`外部数据库`，这样就不需要上一步中的操作，只需要直接在扫描时指定 `db` 源即可。   
查看了 `github` 上有关 `trivy_db` 的仓库，他虽然有一个 `docker image`，但是并不是一个可以直接使用的镜像，具体使用方法还没研究透，至此自己创建 `db` 镜像的想法搁置了。


3. 搭建一个 `trivy` 服务   
按照 `1` 中的方案，每次扫描的时候，只需要调用自己构建的 `images` 并指定 `缓存路径` 就可以。   
但是作为一个安全工具，`trivy` 的数据库是动态更新的。官方每 `12小时`会更新自己的数据库，所以如果你的 `缓存数据库` 时间过久就需要在扫描之前`更新数据库`。   
当然可以通过类似 `--skip-db-update` 的参数进行跳过，但是最新的安全漏洞就无法扫描了。   
如果每次扫描镜像之前都更新一下 `基础镜像` 也是不现实的，首先很多生产环境是纯内网的，无法在 `ci` 过程中进行`数据库更新`，再就是这就会拉长整个扫描的时间。   
后来在文档在发现 `trivy` 支持 `server模式` ，客户端只需要将镜像推给 `server`，`server` 就可以对镜像进行扫描。   
这种模式下只要保持 `server` 是`最新的数据库`就可以。   

4. `server` 模式下的 `docker login`   
在使用 `server` 之后，又有了一个问题就是怎么让 `server` 也能访问`私有仓库`中的 `image`。   
尝试了各种方式，各种位置的 `docker login` 之后，发现了 `trivy` 文档中早就给出了解决方案。只需要添加 `username` 和 `password` 即可。   



以上就是在使用 `trivy` 时踩得几个坑，后续遇到其他问题再重新记录。