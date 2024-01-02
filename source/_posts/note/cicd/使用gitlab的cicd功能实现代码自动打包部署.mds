---
title: 使用gitlab的cicd功能实现代码自动打包部署
tags:
  - cicd
  - gitlab
  - sonar
  - trivy
categories:
  - note
abbrlink: 59b9403b
date: 2023-06-30 00:00:00
---


# 使用 gitlab 的 cicd 功能实现代码自动打包部署

## 背景及大体思路说明

*本文主要是作为一个记录，具体的基础知识，比如 `helm` , `trivy` 等单独记录。*

以往代码库使用的是 `gogs` ，`cicd` 过程使用的是 `Jenkins` ，如果想推送代码后自动构建需要进行 `webhook` 之类的配置。
集成度更高一点的 `gitlab`，`GitHub` 等仓库现在都自带构建功能。
新公司使用的是 `gitlab`，所以研究一下。
感官上类似于 `teamcity` 的使用感觉。添加好流程之后，会选择可用的 `agent` 来进行构建。

构建大体流程也是类似的，在 `pipeline` 中定义构建，测试，发布的流程。
`agent` 根据不同的流程完成不同的任务。

下边就以 `python` 项目和 `asp.net` 项目为例，记录一下研究过程。

## 基础环境搭建
本次并没搭建基础环境，`gitlab`，`sonar`，`harbor` 等都是配置好的。

## 项目配置
在创建项目后，需要在项目的 `cicd` 设置中进行一些配置。
1. 配置runner
`runner` 个人理解类似于 `teamcity` 的 `agent` ，区别在于 `teamcity` 我使用的过程中发现所有的 `agent` 都是共享的。 `gitlab` 的 `runner` 则是可以共享，也可以给项目单独创建。
单独创建支持 `windows`、`linux`、`macos` 三种操作系统以及基于容器创建，也很方便。
但是因为我没有 `gitlab` 的管理员权限，这里使用了共享的 `runner`。
无论使用哪种 `runner`，都要在 `cicd` 的 `runner` 配置中进行配置。如果使用共享 `runner`，直接勾选使用共享即可。

2. 配置变量列表
`gitlab` 的 `cicd` 功能也支持预置变量，可以将一些密码，`token` 之类的提前配置好，这样在 `pipeline` 中直接使用就可以了，避免明文造成数据泄露。
我这里添加了四个变量：

|变量名|变量说明|
|-|-|
|HARBOR_PASS|用于登录harbor服务器的密码|
|HARBOR_USER|用于登录harbor服务器的账号|
|SONAR_HOST_URL|sonar服务器的地址|
|SONAR_TOKEN|sonar服务中项目的凭证|
在variables配置中依次添加即可。

## 编写pipeline-.gitlab-ci.yml

`gitlab` 的 `cicd `使用的 `pipeline` 名叫 `.gitlab-ci.yml`。需要加入到项目的根目录下。作为项目文件提交到 `git` 上。
`gitlab` 的 `cicd `会根据 `.gitlab-ci.ym` l中定义的步骤创建 `pipeline` 和 `job`。

这里有一些使用过程中遇到的坑，记录一下。
1. 文件最开始可以定义 `tags`，这里的 `tags` 对应的就是` runner` 列表中不同` runner` 的 `tags`。如果这里不定义，就找不到 `runner` 执行任务。所以要在这里选择合适的 `runner`。
2. 每一个单独步骤，都会使用指定的 `image` 来构建容器。这里需要注意，如果你的 `image` 需要登录才能拉取的话，会有问题。我尝试通过 `before_script` 功能来提前登录拉取镜像，但是并未成功。每个 `stage` 中的 `before_script` 是当你拉取下来之后才会执行的操作。他和你的 `scripts` 在同一个环境，所以没有作用。全局的 `before_script` 也不好用，我配置了之后在整个构建的最后才执行，不确定逻辑。
3. 类似附件中使用的 `tivry` 功能，会生成一个文件。这个产物可以在 `gitlab` 的 `pipeline` 页面，找到这次的 `pipeline` 后，点击下载按钮下载到本地。

## 附件：实验用的两个pipeline。

* pythonDemo
```yml
default:
  tags:
    - linux-docker-build

stages:
  - sonarqube-check
  - build
  - container_scanning
  
variables:
  IMAGE_NAME: harbor.xxx/devops/pythondemo
  IMAGE_VERSION: $CI_COMMIT_SHORT_SHA
  TRIVY_CACHE_DIR: ".trivycache/"

sonarqube-check:
  stage: sonarqube-check
  image:
    name:  harbor.xxx/cicd/docker-buildbox-linux:8.2.2
    entrypoint: [""]
  variables:
    SONAR_USER_HOME: "${CI_PROJECT_DIR}/.sonar"  # Defines the location of the analysis task cache
    GIT_DEPTH: "0"  # Tells git to fetch all the branches of the project, required by the analysis task
  cache:
    key: "${CI_JOB_NAME}"
    paths:
      - .sonar/cache
  script:
    - /usr/share/sonar-scanner-cli/sonar-scanner-4.7.0.2747-linux/bin/sonar-scanner
  allow_failure: true
  rules:
    - if: '$CI_COMMIT_BRANCH == "master"'

build:
  stage: build
  image: harbor.xxx/cicd/mgoltzsche/podman@sha256:4223d29239c45fda33f8d7c4fa95b34da7a1d479cbf6cb4194769dc021fab0f4
  script:
    - docker login -u $HARBOR_USER -p $HARBOR_PASS  harbor.xxx
    - docker build -t $IMAGE_NAME:$IMAGE_VERSION .
    - docker push $IMAGE_NAME:$IMAGE_VERSION

container_scanning:
  stage: container_scanning
  image:
    name: harbor.avepoint.net/basic/trivy@sha256:e11e055f11fcc06425472a9f7c118ef0fe043cc4404da7d7dcbe7ce356281d2b
    entrypoint: [""]
  variables:
    # No need to clone the repo, we exclusively work on artifacts.  See
    # https://docs.gitlab.com/ee/ci/runners/README.html#git-strategy
    TRIVY_USERNAME: "$HARBOR_USER"
    TRIVY_PASSWORD: "$HARBOR_PASS"
    TRIVY_AUTH_URL: "$harbor.xxx"
    TRIVY_NO_PROGRESS: "true"
    TRIVY_CACHE_DIR: ".trivycache/"
    FULL_IMAGE_NAME: $IMAGE_NAME:$IMAGE_VERSION
  script:
    # 输出到控制台
    - time trivy image --download-db-only --insecure --clear-cache
    - time trivy image --exit-code 0 "$FULL_IMAGE_NAME" --insecure --clear-cache
    - time trivy image --exit-code 1 --severity CRITICAL "$FULL_IMAGE_NAME" --insecure --clear-cache
  cache:
    paths:
      - .trivycache/
  artifacts:
    when:                          always
    reports:
      container_scanning:          gl-container-scanning-report.json


```

* dotnetDemo
```yml
default:
  tags:
    - linux-docker-build

stages:
  - sonarqube-check
  - build
  - container_scanning

variables:
  IMAGE_NAME: harbor.xxx/devops/dotnetdemo
  IMAGE_VERSION: $CI_COMMIT_SHORT_SHA
  TRIVY_CACHE_DIR: ".trivycache/"


sonarqube-check:
  stage: sonarqube-check
  image:  harbor.xxx/cicd/docker-buildbox-linux:8.2.2
  variables:
    SONAR_USER_HOME: "${CI_PROJECT_DIR}/.sonar"  # Defines the location of the analysis task cache
    GIT_DEPTH: "0"  # Tells git to fetch all the branches of the project, required by the analysis task
  cache:
    key: "${CI_JOB_NAME}"
    paths:
      - .sonar/cache
  script: 
      - dotnet sonarscanner begin /k:Devops /d:sonar.token=$SONAR_TOKEN /d:sonar.host.url=$SONAR_HOST_URL
      - dotnet build
      - dotnet sonarscanner end /d:sonar.token=$SONAR_TOKEN
  allow_failure: true
  rules:
    - if: $CI_COMMIT_BRANCH == 'master'


build:
  stage: build
  image: harbor.xxx/cicd/mgoltzsche/podman@sha256:4223d29239c45fda33f8d7c4fa95b34da7a1d479cbf6cb4194769dc021fab0f4
  script:
    - docker login -u $HARBOR_USER -p $HARBOR_PASS  harbor.xxx
    - docker build -t $IMAGE_NAME:$IMAGE_VERSION .
    - docker push $IMAGE_NAME:$IMAGE_VERSION





container_scanning:
  stage: container_scanning
  image:
    name: harbor.avepoint.net/basic/trivy@sha256:e11e055f11fcc06425472a9f7c118ef0fe043cc4404da7d7dcbe7ce356281d2b
    entrypoint: [""]
  variables:
    # No need to clone the repo, we exclusively work on artifacts.  See
    # https://docs.gitlab.com/ee/ci/runners/README.html#git-strategy
    GIT_STRATEGY: none
    TRIVY_USERNAME: "$HARBOR_USER"
    TRIVY_PASSWORD: "$HARBOR_PASS"
    TRIVY_AUTH_URL: "$harbor.xxx"
    TRIVY_NO_PROGRESS: "true"
    TRIVY_CACHE_DIR: ".trivycache/"
    FULL_IMAGE_NAME: $IMAGE_NAME:$IMAGE_VERSION
  script:

    # 输出到控制台
    - time trivy image --download-db-only --insecure --clear-cache
    - time trivy image --exit-code 0 "$FULL_IMAGE_NAME" --insecure --clear-cache
    - time trivy image --exit-code 1 --severity CRITICAL "$FULL_IMAGE_NAME" --insecure --clear-cache
  cache:
    paths:
      - .trivycache/
  artifacts:
    when:                          always
    reports:
      container_scanning:          gl-container-scanning-report.json

```