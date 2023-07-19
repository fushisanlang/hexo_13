---
title: django学习(1)-创建项目
date: 2019-4-7
updated: 2019-4-8
tags:
  - python
  - django
categories:
  - note
abbrlink: 7d5ad592
---

# django学习(1)-创建项目

### 安装环境

redhat 7.4 64bit

python 3.6.6



### 安装Djanjo

```shell
[python@localhost ~]$ sudo python3 install Djanjo==1.11 
#参考教程为1.11版，所以此处也安装相同版本的djindo。该版本支持到2020年4月。
```



### 项目说明

> 旨在建立一个笔记记录系统。用户能够记录笔记，并归档于不同的主题。
>
> 主页是网站的描述以及注册登录窗口。
>
> 登录后可以创建新主题，添加新条目以及阅读现有条目。


<!--more-->
### 项目建立

```shell
[python@localhost ~]$ django-admin.py startproject own_note .
#执行完上述命令，会在当前路径下，建立一个名为learning_log的项目,以及一个manage.py的文件
[python@localhost ~]$ ls .
manage.py  own_note
[python@localhost ~]$ ls own_note
__init__.py  __pycache__  settings.py  urls.py  wsgi.py
```



### 建立数据库

```shell
[python@localhost ~]$ python manage.py migrate
#使用sqlite作为数据库。
[python@localhost ~]$ ls .
db.sqlite3  manage.py  own_note
```

* 可能会遇见的问题

  * `ModuleNotFoundError: No module named '_sqlite3' ` 

    此报错是因为系统中未安装sqlite-devel导致。

    `yum install sqlite-devel`后重新编译安装python即可。

  * `django.core.exceptions.ImproperlyConfigured: SQLite 3.8.3 or later is required (found 3.7.17).`

    此报错是因为系统中安装的sqlite版本过低。最新版本的Djanjo需要sqlite>3.8。但是linux自带的sqlite版本为3.7 。可以通过安装高版本sqlite或低版本djindo达到兼容。

### 查看项目

```shell
[python@localhost ~]$ python manage.py runserver
Performing system checks...

System check identified no issues (0 silenced).
August 30, 2019 - 02:32:36
Django version 1.11, using settings 'learning_log.settings'
Starting development server at http://127.0.0.1:8000/
Quit the server with CONTROL-C.
#此时通过浏览器访问8000端口即可
```

