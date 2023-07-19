---
title: git基础
date: 2016-4-11
updated: 2016-4-12
tags:
  - git
categories:
  - note
abbrlink: 9891ebc8
---

```shell
mkdir /git_dir
cd /git_dir
git init
```
<!--more-->
```shell
vim readme.md
	## this is 13's test git_dir
	## use for learn git 

git add readme.md   #添加文件，可反复多次，添加多个文件
git commit -m <message>   #将添加操作提交  message为相应信息，建议此处输入可读性强的信息
```

```shell
 git status #查看仓库当前的状态
 git diff readme.md #对比
```

```shell
git log # 历史记录
git log --pretty=oneline #简略版历史记录
git reset --hard HEAD^ #返回上一次修改
git reset --hard id  #返回id标明的修改
git reflog #查看命令历史
```

