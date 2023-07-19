---
title: 使用gitlab的cicd功能实现代码自动打包部署-2
tags:
  - cicd
  - gitlab
  - sonar
  - trivy
  - aks
  - helm
categories:
  - note
abbrlink: e34aee81
date: 2023-06-30 00:00:00
---


# 使用gitlab的cicd功能实现代码自动打包部署-2

## 背景
书接上回[使用gitlab的cicd功能实现代码自动打包部署](https://www.fushisanlang.cn/article/59b9403b.html)，之前只是完成了构建的功能，并没有部署的功能，这里将继续完成部署的部分。   
本文主要是作为一个记录，具体的基础知识，比如 `helm` , `trivy` 等单独记录。

## 基于上文的一些修改
1. 将两个项目合并到了一起，用来模拟一个微服务架构下的两个服务。   
2. 为两个项目都配置了一个 `api` 接口 `/api/health` ， 这个接口的返回值是 `{"version":"xxxxx"}` ,其中 `xxx` 是 `gitlab` 中 `cicd` 的 `pipelineid`，用于健康检查。

## 添加helm部署

因为通过 `cicd`，将代码打包成了 `docker image`，后续如果想要部署，就要依托于容器生态。   
这里使用 `helm` 进行部署。   
`helm` 相关信息可以看[这个文档](https://helm.sh/zh/docs/)，写的比较好，后续我也会根据自己理解写一个小的笔记。   
具体实现中，我们只需要按照 `helm chart` 的格式将我们的 `chart` 写好，然后使用 `helm install` 或者 `helm upgrade` 部署升级即可。   
  
具体 `demo` 见附件。   

## 添加健康检查

在所有部署完成之后，需要一个检查。   
这个检查包含两个部分：
1. 检查服务是否正常启动
2. 检查启动的服务版本是否是最新构建

在检查完成之后，通过企业微信的 `webhook` 机器人通知。



## 继续小tips
上文说了一些实际使用中遇到的问题，这里再补充一下。   
1. 对于之前说的无法在 `stage` 中先登录，后拉取私有镜像进行构建的问题，找到了解决方法。   
*这里补充一下，是在官方文档中找到的，所以以后还是多看官方文档*   
具体解决方法很简单，只需要在 `gitlab` 的 `cicd` 配置中，添加一个变量如下：
```
DOCKER_AUTH_CONFIG:
{
    "auths": {
        "harbor.xxx": {
            "auth": "amVmZnJleS56aGFuZzpGdXNoaXNhbmxhbmcx"
        }
    }
}
```
这个变量其实就是在命令行中执行 `docker login` 之后生成登录凭证。我们只需要把这个凭证存入 `cicd` 中即可。   
官网还给了其他的解决方法，但是我觉得这个配置方法最好，其他的都要在更改代码库本身。

2. 我在修改过的流程中，通过一个 `version` 变量将 `pipeline` 的 `id` 传入了镜像内，作为了一个环境变量。   
但是在使用中有个问题，就是这个变量读不到。   
多次实验之后发现，在 `dockerfile` 中，`arg` 和 `env` 需要挨着才可以，如果 `arg` 先定义好，然后执行其他命令之后才通过 `env` 配置环境变量，实际打包好的 `image` 就没有这个变量。具体原因还在探索，这里作为踩坑记录先行保留。   
具体内容如下：
```
ARG BASE_IMAGE
FROM $BASE_IMAGE

ARG IMAGE_VERSION
ENV version $IMAGE_VERSION  #注意这里的用法，就是我说的arg和env要连在一起。

WORKDIR /pydemo
COPY requirements.txt ./
RUN pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
COPY demo.py .
EXPOSE 5000
CMD ["python", "demo.py"]
```

3. 输出文件的下载   
因为使用了 `trivy` 进行镜像扫描，他的扫描结果有时候需要下载，但是假如我生成了多个镜像，扫描的时候要逐个扫描（这里尝试下来没法一条命令扫描多个镜像），这样会生成多个结果文件。但是 `cicd` 本身的 `report` 只支持输出一个文件。   
最开始选择的是通过 `tar` 命令压缩，但是 `.tar.gz` 文件能输出了，不过下载后的文件后缀是 `.json`。需要改名之后才能用。  
后来翻阅了一下文档，找到了如下配置：
```
artifacts:
    untracked: true  #这个参数
    when: always
```

官方说法是：
> 当设置untracked: true时，CI/CD作业会将未跟踪的文件（即未被Git跟踪的文件）包括在产物中。这些未跟踪的文件可能是在构建过程中生成的临时文件或其他不需要被Git追踪的文件。通过将untracked设置为true，可以确保这些未跟踪的文件也被包括在CI/CD作业的产物中，以便后续的步骤可以使用或处理这些文件。

使用这个参数之后，会把整个输出目录导出以供下载，只需要配置好路径，就能把整个流程中需要保存的文件都保存下来。

## 附件：

#### 附件1： python project dockerfile

```dockerfile
ARG BASE_IMAGE
FROM $BASE_IMAGE

ARG IMAGE_VERSION
ENV version $IMAGE_VERSION

WORKDIR /pydemo
COPY requirements.txt ./
RUN pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
COPY demo.py .
EXPOSE 5000
CMD ["python", "demo.py"]

```

#### 附件2： dotnet project dockerfile

```dockerfile
ARG BASE_SDK_IMAGE   BASE_ASP_IMAGE   
FROM $BASE_SDK_IMAGE AS build
WORKDIR /app
COPY ./*.csproj ./
RUN dotnet restore
COPY . ./
RUN dotnet publish -c Release -o out

FROM $BASE_ASP_IMAGE AS runtime
ARG IMAGE_VERSION
ENV IMAGE_VERSION=$IMAGE_VERSION
WORKDIR /app
COPY --from=build /app/out .
EXPOSE 8080
ENTRYPOINT ["dotnet", "dotnetDemo.dll"]

```


#### 附件3: gitlab-cli.yml

```yml
default:
  tags:
    - linux-docker-build

stages:
  - sonarqube-check
  - build
  - container-scanning
  - deploy-by-helm
  - check-version


variables:
  HARBOR_URL: harbor.xxx
  IMAGE_NAME_DOTNET: $HARBOR_URL/devops/dotnetdemo
  IMAGE_NAME_PYTHON: $HARBOR_URL/devops/pythondemo
  IMAGE_VERSION: $CI_PIPELINE_ID
  TRIVY_CACHE_DIR: $CI_PROJECT_DIR
  TRIVY_SERVER: http://10.1.169.112:10000
  DOMAIN: c4893a3171c1456fbd55.eastus.aksapp.io
  PYTHON_DOMAIN: aks-python.$DOMAIN
  DOTNET_DOMAIN: aks-dotnet.$DOMAIN
  

  
sonarqube-check:
  stage: sonarqube-check
  image:
    name:  harbor.xxx/devops/sonar-scanner-cli:latest
    entrypoint: [""]
  variables:
    SONAR_USER_HOME: "${CI_PROJECT_DIR}/.sonar" 
    GIT_DEPTH: "0" 
  cache:
    key: "${CI_JOB_NAME}"
    paths:
      - .sonar/cache
  script:
   - sonar-scanner
  allow_failure: true
  rules:
    - if: '$CI_COMMIT_BRANCH == "1"'

build:
  stage: build  
  image: harbor.xxx/cicd/mgoltzsche/podman:5.1
  script:
    - docker login -u $HARBOR_USER -p $HARBOR_PASS  $HARBOR_URL
    - cd dotnet
    - docker build --build-arg BASE_SDK_IMAGE=harbor.xxx/cicd/dotnet/sdk:6.0 --build-arg BASE_ASP_IMAGE=harbor.xxx/cicd/dotnet/aspnet:6.0-alpine3.17 --build-arg IMAGE_VERSION=$IMAGE_VERSION -t $IMAGE_NAME_DOTNET:$IMAGE_VERSION  .
    - docker push $IMAGE_NAME_DOTNET:$IMAGE_VERSION
   
    - cd ../python
    - docker build --build-arg BASE_IMAGE=harbor.xxx/cicd/python:3.11.0-slim --build-arg IMAGE_VERSION=$IMAGE_VERSION -t $IMAGE_NAME_PYTHON:$IMAGE_VERSION .
    - docker push $IMAGE_NAME_PYTHON:$IMAGE_VERSION   
  rules:
    - if: '$CI_COMMIT_BRANCH == "1"'


container-scanning:
  stage: container-scanning
  image:
    name:   harbor.xxx/devops/trivy:latest
    entrypoint: [""]
  script:
    - mkdir -p $CI_PROJECT_DIR
    - time trivy image --exit-code 0  --server $TRIVY_SERVER --username $HARBOR_USER --password $HARBOR_PASS --format template --template "@/contrib/gitlab.tpl" --output "$TRIVY_CACHE_DIR/dotnet-scanning-report.json" $IMAGE_NAME_DOTNET:$IMAGE_VERSION    
    - time trivy image --exit-code 0  --server $TRIVY_SERVER --username $HARBOR_USER --password $HARBOR_PASS --format template --template "@/contrib/gitlab.tpl" --output "$TRIVY_CACHE_DIR/python-scanning-report.json" $IMAGE_NAME_PYTHON:$IMAGE_VERSION
   
  artifacts:
    untracked: true
    when: always
  rules:
    - if: '$CI_COMMIT_BRANCH == "1"'


deploy-by-helm:
  stage: deploy-by-helm
  image: harbor.xxx/cicd/mgoltzsche/podman:5.1
  script:
    - cd cidemo-chart
    - docker run -v `pwd`/../config:/tmp/config.aks harbor.avepoint.net/cicd/helm-kubectl-yq:alpine-3.17.2 helm --kubeconfig /tmp/config.aks upgrade cidemo --set pythonDomain=$PYTHON_DOMAIN,dotnetDomain=$DOTNET_DOMAIN,pythonImageTag=$IMAGE_VERSION,dotnetImageTag=$IMAGE_VERSION  .
  rules:
    - if: '$CI_COMMIT_BRANCH == "1"'
check-version:   
  stage: check-version  
  image: harbor.xxx/cicd/mgoltzsche/podman:5.1
  script:
    - docker login -u $HARBOR_USER -p $HARBOR_PASS  $HARBOR_URL  
    - echo http://$PYTHON_DOMAIN/api/health
    - docker run --rm --network=host  harbor.xxx/devops/checkhealth:latest python checkHealth.py v3 19d6257a-8ed8-4e09-b802-9f79107d2258 http://$PYTHON_DOMAIN/api/health  PYTHON
    - docker run --rm --network=host  harbor.xxx/devops/checkhealth:latest python checkHealth.py v4 19d6257a-8ed8-4e09-b802-9f79107d2258 http://$DOTNET_DOMAIN/api/health  DOTNET 
  rules:
    - if: '$CI_COMMIT_BRANCH == "master"'

```



#### 附件4：chart values.yaml
```yml
namespace: ci_demo
pythonReplicas: 1
dotnetReplicas: 1
pythonImageTag: v2

```

#### 附件5：chart remplates service.yaml
```yml
apiVersion: v1
kind: Service
metadata:
  name: python-service
spec:
  type: ClusterIP
  ports:
  - port: 50001 
  selector:
    app: python-app
---
apiVersion: v1
kind: Service
metadata:
  name: dotnet-service
spec:
  type: ClusterIP
  ports:
  - port: 50001 
  selector:
    app: dotnet-app

```

#### 附件6：chart remplates deployment.yaml
chart remplates deployment.yaml
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: python-app
spec:
  replicas: {{ .Values.pythonReplicas }}
  selector:
    matchLabels:
      app: python-app
  template:
    metadata:
      labels:
        app: python-app
    spec:
      containers:
        - name: python-app
          image: harbor.xxx/devops/pythondemo:{{ .Values.pythonImageTag }}
          ports:
          - containerPort: 50001

--- 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dotnet-app
spec:
  replicas: {{ .Values.dotnetReplicas }}
  selector:
    matchLabels:
      app: dotnet-app
  template:
    metadata:
      labels:
        app: dotnet-app
    spec:
      containers:
        - name: dotnet-app
          image: harbor.xxx/devops/dotnetdemo:{{ .Values.dotnetImageTag }}
          ports:
          - containerPort: 8080

```




#### 附件7：chart remplates ingress.yaml
chart remplates ingress.yaml
```yml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: python-ingress
  annotations:
    kubernetes.io/ingress.class: addon-http-application-routing
spec:
  rules:
    - host: {{ .Values.pythonDomain }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: python-service
                port:
                  number: 50001
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: dotnet-ingress
  annotations:
    kubernetes.io/ingress.class: addon-http-application-routing
spec:
  rules:
    - host: {{ .Values.dotnetDomain }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: dotnet-service
                port:
                  number: 50001

```


#### 附件8： checkHealth.py

```python
import requests
import json
import sys
#set off ssl
import ssl
ssl._create_default_https_context = ssl._create_unverified_context

def sendMessage(rebotKey,messageStr):
  rebotUrl="https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=" + rebotKey 
  rebotHeaders = {'Content-Type': 'application/json'}
  rebotData = {
        "msgtype": "text",
        "text": {
            "content": messageStr
        }
   }
  r=requests.post(rebotUrl,headers=rebotHeaders,data=json.dumps(rebotData))
  if r.status_code!=200:
      sys.exit(1)
  return



try:
  newVersion=sys.argv[1]
  rebotKey = sys.argv[2]    # "19d6257a-8ed8-4e09-b802-9f79107d2258"        
  checkUrl = sys.argv[3]   #checkUrl="http://aks.c4893a3171c1456fbd55.eastus.aksapp.io/api/health"
  serverName = sys.argv[4]
except:
  messageStr=serverName + ": I need you to give me a version number first."
  sendMessage(rebotKey,messageStr)
  sys.exit()

try:
  checkResp=requests.get(checkUrl)
  checkVersion=checkResp.json()["version"]
except:
  messageStr=serverName + ": I didn't get the version number."
  sendMessage(rebotKey,messageStr)
  sys.exit()
else:
  if newVersion == checkVersion:
      sendMessage(rebotKey,serverName + ": I got the version number " + checkVersion + ",same as what you gave me.")
  else:
      sendMessage(rebotKey,serverName + ": I got the version number " + checkVersion + ",different from the version number " + newVersion + "you gave me.")

```