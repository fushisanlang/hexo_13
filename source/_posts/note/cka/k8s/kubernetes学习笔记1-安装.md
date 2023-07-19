---
title: kubernetes学习笔记1-集群部署
tags:
  - cka
  - k8s
  - kubernetes
categories:
  - note
abbrlink: e484b8e4
date: 2022-10-31 00:00:00
---

*个人CKA学习笔记，大部分内容源于《CKA/CKAD应试指南-从Docker到Kubernetes完全攻略》一书。*
# kubernetes学习笔记1-集群部署



### kuberbetes架构及组件介绍

##### master上运行的组件及作用
|组件名称|作用|
|-|-|
|kubectl|命令行工具，通过他来创建，删除资源|
|api-server|接口，用来接收用户发送的请求|
|scheduler|调度器，创建pod时，判定在哪个worker上工作|
|controller-manager|监测节点状态，pod数目等|

##### worker上运行的组件及作用

|组件名称|作用|
|-|-|
|kubelet|代理，接受master分配过来的任务，并将节点信息反馈给master上的api-server|
|kube-proxy|用于把发送个service的请求转发给后端的pod，其模式有iptables和ipvs|
|calico|使节点中的pod能够互相通信|

### 安装

##### 环境介绍

|IP|HOSTNAME|mem|OS|role|
|-|-|-|-|-|
|192.168.122.100|k8s-m.fushisanlang.cn|4GB|CentOS Linux release 7.9.2009 (Core)|master and worker|
|192.168.122.101|k8s-s1.fushisanlang.cn|4GB|CentOS Linux release 7.9.2009 (Core)|worker|
|192.168.122.102|k8s-s2.fushisanlang.cn|4GB|CentOS Linux release 7.9.2009 (Core)|worker|

##### 环境准备
在安装kubernetes前，需要的主机进行一些设置，这些设置需要在`所有主机`上进行操作。

1. 配置hosts或 [配置简易DNS服务器](https://www.fushisanlang.cn/article/675265e9.html)，使所有主机间的hostname可以互相识别

```shell
echo '192.168.122.100 k8s-m.fushisanlang.cn' >> /etc/hosts
echo '192.168.122.101 k8s-s1.fushisanlang.cn' >> /etc/hosts
echo '192.168.122.102 k8s-s2.fushisanlang.cn' >> /etc/hosts
```
  
 
2. 关闭防火墙及selinux   

```shell
systemctl stop firewalld
systemctl disable firewalld
setenforce 0
vim  /etc/selinux/config  
  SELINUX=disabled #修改
```

3. 关闭swap
```shell
swapoff -a
sed -i '/swap/s/UUID/#UUID/g' /etc/fstab
```
4. 配置yum源
```shell
cd /etc/yum/repos.d/
mkdir bak
mv *bak
wget https://download.fushisanlang.cn/yum.repos/CentOS-Base.repo
wget https://download.fushisanlang.cn/yum.repos/docker-ce.repo
wget https://download.fushisanlang.cn/yum.repos/epel.repo
wget https://download.fushisanlang.cn/yum.repos/k8s.repo
```

5. 安装docker并配置自启
```shell
yum install docker-ce -y
systemctl enable docker --now
```

6. 设置内核参数
```shell
echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.d/k8s.conf 
echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.d/k8s.conf 
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/k8s.conf 
sysctl -p /etc/sysctl.d/k8s.conf
#注意需要先启动docker再修改参数，不然会报错
```

7. 安装软件包
```shell
yum install -y kubelet-1.21.1-0 kubeadm-1.21.1-0 kubectl-1.21.1-0 --disableexcludes=kubernetes
#如果安装时没有指定版本，则安装的是最新版本
```
8. 启动kubelet
```shell
systemctl restart kubelet
systemctl enable kubelet
```

##### 安装master
`在master节点操作`

1. 初始化集群
因为网络问题，使用阿里云的镜像仓库进行集群搭建。
由于阿里云缺少coredns镜像，需要先从ftp.rhce.cc/cks-tool/coredns-1.21.tar处下载，
```shell
#由于阿里云缺少coredns镜像,需要提前下载
wget ftp.rhce.cc/cks-tool/coredns-1.21.tar -O /tmp/coredns-1.21.tar
docker load -i /tmp/coredns-1.21.tar

kubeadm  init \
--image-repository registry.aliyuncs.com/google_containers \  #指定阿里云的镜像仓库
--kubernetes-version=v1.21.1 \ #指定安装版本，需要提前安装对应版本的kubectl，kubeadm，kubelet
--pod-network-cidr=10.244.0.0/16 #指定pod的网段

#上述命令执行之后，会有一个用于将worker加入集群的命令提示：
# kubeadm join 192.168.122.100:6443 --token i5sqtk.ekvz51wnlt5ujmyo --discovery-token-ca-cert-hash sha256:cd8db6e508b5d15a3e87217c3c5b8b085735c023b8f6446e1c3315831000763b
#如果看见类似提示，说明初始化成功
```

2. 复制kubeconfig文件
```shell
mkdir -p ~/.kube
cp -i /etc/kubernetes/admin.conf ~/.kube/config
chown root:root ~/.kube/config
```
3. 创建token
初始化集群过程中，生成的token有效期一般只有24小时，如果忘记保存或者超过有效期了，就要重新生成
```shell
kubeadm token list #查看token
kubeadm token create #生成token
kubeadm token create --print-join-command #获取加入集群的命令，可以直接在worker节点上粘贴
```

##### 配置worker加入集群
`在workerr节点操作`

```shell
kubeadm join 192.168.122.100:6443 --token i5sqtk.ekvz51wnlt5ujmyo --discovery-token-ca-cert-hash sha256:cd8db6e508b5d15a3e87217c3c5b8b085735c023b8f6446e1c3315831000763b
# 此命令可以通过在master节点上输入 kubeadm token create --print-join-command 后获得
```
##### 安装calico网络
1. 查看节点状态
`在master节点操作`

```shell
kubectl get nodes
#发现三个节点都可以显示，但是status是notready的状态。此时需要安装calico网络才能使k8s正常工作。
```

2. 下载用于配置calico的yaml
`在master节点操作`

```shell
wget https://docs.projectcalico.org/v3.19/manifests/calico.yaml --no-check-certificate
```

3. 修改配置
`在master节点操作`

```shell
vim calico.yaml
```
```yaml
#找到CALICO_IPV4POOL_CIDR配置
            # - name: CALICO_IPV4POOL_CIDR
            #   value: "192.168.0.0/16"
#将此处修改为            
            - name: CALICO_IPV4POOL_CIDR
              value: "10.244.0.0/16"  #这里是创建集群时指定的ip范围
#注意yml的格式缩进
```

4. 准备镜像
`在三个节点都要操作`
```shell
grep image calico.yaml
#会显示出需要的镜像如下：
#          image: docker.io/calico/cni:v3.19.4
#          image: docker.io/calico/cni:v3.19.4
#          image: docker.io/calico/pod2daemon-flexvol:v3.19.4
#          image: docker.io/calico/node:v3.19.4
#          image: docker.io/calico/kube-controllers:v3.19.4
#在三台机器上通过docker pull命令提前准备好所有镜像，如果不在worker上准备镜像，会导致安装失败

#准备好后开始安装
kubectl apply -f calico.yaml
```

5. 验证结果
`在master节点操作`
```shell
kubectl get nodes
#此时可以发现status都是Ready的状态了
NAME                     STATUS   ROLES                  AGE     VERSION
k8s-m.fushisanlang.cn    Ready    control-plane,master   2d21h   v1.21.1
k8s-s1.fushisanlang.cn   Ready    <none>                 3h35m   v1.21.1
k8s-s2.fushisanlang.cn   Ready    <none>                 2d21h   v1.21.1
```
##### 设置命令tab补全
`在master节点操作`
1. 安装bash-completion
``` shell
yum install -y bash-completion
```
2. 配置环境变量
```shell
sed '2asource <(kubectl completion bash)' -i /etc/profile 
source /etc/profile 
```