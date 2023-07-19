---
title: helm基础
date: 2023-7-10
tags:
  - k8s
  - helm
  - cka
categories:
  - note
abbrlink: cb722c6b
---

# helm基础

## 简介
`Helm` 是 `Kubernetes` 的包管理器，类似 `python` 的 `pip` 和 `centos` 中的 `yum`。   
具体文档可以看这个： [helm.sh](https://helm.sh/zh/docs/intro/quickstart/) 。

## 使用的先决条件

* 一个 `Kubernetes` 集群
* 确定你安装版本的安全配置
* 安装和配置 `Helm`

## 安装

* 可以通过系统的包管理器安装，比如 `apt` 或者 `dnf`。

* 也可以通过下述方法安装：
```shell
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

* 也可以直接下载 `Canary` 构建。   
这些不是官方版本，可能不稳定。但是这提供测试边缘特性的条件。地址如下：

  * [linux](https://get.helm.sh/helm-canary-linux-amd64.tar.gz)
  * [macos](https://get.helm.sh/helm-canary-darwin-amd64.tar.gz)
  * [windows](https://get.helm.sh/helm-canary-windows-amd64.zip)

## 使用

### 三个基本概念
`Chart` 代表着 `Helm` 包。它包含在 `Kubernetes` 集群内部运行应用程序，工具或服务所需的所有资源定义。你可以把它看作是 `Homebrew formula`，`Apt dpkg`，或 `Yum RPM` 在 `Kubernetes` 中的等价物。

`Repository（仓库）` 是用来存放和共享 `charts` 的地方。它就像 `Perl` 的 `CPAN 档案库网络`或是 `Fedora` 的`软件包仓库`，只不过它是供 `Kubernetes` 包所使用的。

`Release` 是运行在 `Kubernetes` 集群中的 `chart` 的实例。一个 `chart` 通常可以在同一个集群中安装多次。每一次安装都会创建一个新的 `release`。以 `MySQL chart` 为例，如果你想在你的集群中运行两个数据库，你可以安装该 `chart` 两次。每一个数据库都会拥有它自己的 `release` 和 `release name`。

使用 `helm` 安装软件即：  
`Helm` 安装 `charts` 到 `Kubernetes` 集群中，每次安装都会创建一个新的 `release`。你可以在 `Helm` 的 `chart repositories` 中寻找新的 `chart`。

### 常用命令
```shell 
helm completion # 为指定的shell生成自动补全脚本
helm create # 使用给定的名称创建chart
helm dependency # 管理chart依赖
helm env # helm客户端环境信息
helm get # 下载命名版本的扩展信息
helm history # 检索发布历史
helm install # 安装chart
helm lint # 验证chart是否存在问题
helm list # 列举发布版本
helm package # 将chart目录打包
helm plugin # 安装、列举或卸载Helm插件
helm pull # 从仓库下载chart并（可选）在本地目录中打开
helm push # 推送chart到远程
helm registry # 从注册表登录或登出
helm repo # 添加、列出、删除、更新和索引chart仓库
helm rollback # 回滚发布到上一个版本
helm search # helm中搜索关键字
helm show # 显示chart信息
helm status # 显示命名版本的状态
helm template # 本地渲染模板
helm test # 执行发布的测试
helm uninstall # 卸载版本
helm upgrade # 升级版本
helm verify # 验证给定路径的chart已经被签名且是合法的
helm version # 打印客户端版本信息
```
## 完成一个自己的helm chart

### 关于chart的个人理解
`chart` 在我感觉就是一个模板化的 `k8s` 中的 `deploy` 文件集合。   
在原来使用 `k8s` 时，会提前定义好比如 `service.yml`,`deployment.yml` 等文件，然后通过 `kubectl apply -f .` 的方式部署。   
这里有个问题就是，比如我需要`升级项目`，镜像版本从 `v1` 变成了 `v2`，就需要更改`对应的文件`，如果我想更改某个 `deployment` 的`部署个数`，也要`修改配置文件`，然后通过 `kubectl` 进行更新。   
这样需要频繁修改 `yml 文件`，一不注意 `yml` 就会解析异常。而且除了`手动备份 yml` 之外，没有`备份`和`历史记录`.   
如果有个回退到某个时间的需要，需要寻找整个项目组所有当时的文件备份，很容易出错。   

而 `helm` 就优化了这一流程。对于仅仅是镜像版本的更新或者部署个数的修改，都可以通过`变量`的方式传入，这样只需要一条` helm 命令`，而不需要修改文件来进行操作。   
对于不同版本的管理，`helm `更是有自己的`部署历史`，可以很`方便的回退到特定的版本`。


总结来说，`Helm`简化了 `Kubernetes` 应用程序的`部署和管理`过程，通过使用`模板化`的 `Chart` 和`值的动态传递`，减少了手动修改 `YAML文件` 的频率，并提供了`版本管理`和`回滚`的功能，方便管理不同版本的应用程序。

### 创建一个helm chart
可以在安装好的 `helm` 服务器上使用 `helm create demo` 命令来创建一个名叫 `demo` 的 `helm chart` 项目。

### 调试模板
```shell 
helm lint # 是验证chart是否遵循最佳实践的首选工具。
helm template --debug # 在本地测试渲染chart模板。
helm install --dry-run --debug #这是让服务器渲染模板的好方法，然后返回生成的清单文件。
helm get manifest #这是查看安装在服务器上的模板的好方法
```

### 更多使用
可以参考这个[ helm 中文文档](https://helm.sh/zh/docs/intro/quickstart/) 。

## 不同文件分析

*需要特别说明，` helm` 并没有强制要求文件名，但是为了方便维护和团队合作，请不要随意命名。*
* Chart.yaml   
这个文件定义了整个 `chart` 的基本信息

* values.yaml   
这里是安装时用来读取的`参数列表`，或者叫`配置文件`。但是他的**优先级是最低的**。   
默认使用 `values.yaml`，可以被`父 chart` 的 `values.yaml` 覆盖，继而被`用户提供 values 文件` 覆盖， 最后会被 `--set 参数`覆盖，优先级为 `values.yaml` 最低， `--set 参数`最高。

* templates   
这里放的就是 `helm chart` 的`模板文件`。项目需要用到的比如 `deployment.yaml`，`service.yaml` 等都要放到这里。

