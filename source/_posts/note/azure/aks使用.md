---
title: aks使用
date: 2023-7-10
tags:
  - azure
  - Azure Cli
  - aks
categories:
  - note
abbrlink: bc0e9e0e
---

# aks 使用
## 背景
公司使用azure提供的k8s托管服务，即aks服务。所以学习了一下aks的一些知识。

## azure cli的部署安装

### 什么是 Azure CLI？
`Azure 命令行接口 (CLI)` 是一个跨平台的`命令行工具`，可连接到 `Azure` 并对 `Azure` 资源执行管理命令。 它允许使用交互式命令行提示符或脚本通过终端执行命令。   
可以在 `Linux`、`Mac` 或 `Windows` 计算机上本地安装 `Azure CLI`。 还可以通过 `Azure Cloud Shell` 在浏览器中使用，或者从 `Docker` 内部运行。   

### 安装
#### 在 Linux 上安装 Azure CLI
```shell
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[azure-cli]
name=Azure CLI
baseurl=https://packages.microsoft.com/yumrepos/azure-cli
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/azure-cli.repo
sudo dnf install azure-cli
```

#### 在 Docker 容器中运行 Azure CLI
```shell
docker run -it mcr.microsoft.com/azure-cli
```

## 通过azure cli连接到aks服务
### 登录
默认可以使用 `az login` 登录，

如果 `CLI` 可以打开默认浏览器，它将初始化授权代码流，并打开默认浏览器来加载 `Azure` 登录页面。

否则，它将启动设备代码流，并指示你打开浏览器页面 (https://aka.ms/devicelogin)，并输入终端中显示的代码。

如果没有可用的 `Web 浏览器`或 `Web 浏览器`无法打开，可通过 `az login --use-device-code` 强制使用设备代码流。

也可以使用其他方式，具体详见 [使用 Azure CLI 登录](https://learn.microsoft.com/zh-cn/cli/azure/authenticate-azure-cli)。

### 安装aks管理端
使用 `az aks install-cli` 安装，实际是安装一个 `kubectl` 命令。我在实际使用中发现访问超时，所以我按照提示的连接手动下载了一个压缩包，将解压后的 `kubectl` 文件放到了`/usr/bin` 中了，也可以使用。

### 认证
按照 `aks` 的连接指南，即可完成认证。示例如下：
```shell
az account set --subscription xxx
az aks get-credentials --resource-group xx --name xx
```

### 安装helm
目前 `azure cli` 还不支持通过 `az` 命令安装 `helm3`，我是自己通过 `dnf` 方式安装的。

### 基础使用
上述配置之后，可以通过 `kubectl` 像是访问`本地集群`一样访问 `aks 集群`。   

### 一些和自建k8s不同的地方
1. 公网ip   
在使用中，我有一个 `ingress`，但是 `azure` 一直没给这个 `ingress` 分配`外部 ip`，即`公网 ip`。   
查了一下发现，如果 `ingress` 需要分配`公网地址`，需要一些特殊配置。   
首先需要在`网络`菜单中 `启用 HTTP 应用程序路由`。   
其次 `ingress` 中需要有一个如下标签。   
```yaml
metadata:
  annotations:
    kubernetes.io/ingress.class: ddon-http-application-routing #这个绑定
```

具体官方文档地址为 [官方文档](https://learn.microsoft.com/zh-cn/azure/aks/http-application-routing) 。

2. 即使有了`公网 ip`，也无法访问   
无法直接通过给分配的`公网 ip` 访问到自己的 `aks 服务`。原因是因为 `azure` 给每个 `aks` 分配了一个 `dns`。    
使用如下命令可以查看分配的 `dns`，结果类似 `c4893a3171c1456fbd55.eastus.aksapp.io`：
```shell
az aks show --resource-group <resource-group> --name <aks-cluster> --query addonProfiles.httpApplicationRouting.config.HTTPApplicationRoutingZoneName -o tsv
```
我们需要给每个 `ingress` 中配置一个 `基于这个 dns 的域名`，类似 `aks.c4893a3171c1456fbd55.eastus.aksapp.io` ,这样就可以通过访问这个域名来访问 `ingress`。   
当然也可以使用其他方式将服务代理出去，具体可以查看官方文档：[将静态公共 IP 地址和 DNS 标签用于 Azure Kubernetes 服务 (AKS) 负载均衡器](https://learn.microsoft.com/zh-cn/azure/aks/static-ip) 。
