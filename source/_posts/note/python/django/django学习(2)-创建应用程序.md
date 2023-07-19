---
title: django学习(2)-创建应用程序
date: 2020-2-19
updated: 2020-2-20
tags:
  - python
  - django
categories:
  - note
abbrlink: 163ad583
---
# django学习(2)-创建应用程序

### 创建应用程序

```shell
#新开一个终端，切换到manage.py所在目录
[python@localhost ~]$ python manage.py startapp own_notes
[python@localhost ~]$ ls
db.sqlite3  manage.py  own_note  own_notes
#此时，在当前目录下生成了own_notes目录
[python@localhost ~]$ ls own_notes
admin.py  apps.py  __init__.py  migrations  models.py  tests.py  views.py
```

### 定义模型

* models.py

```shell
vim models.py
```

```python
from django.db import models

class Topic(models.Model):
    text = models.CharField(max_length=200)
    date_added = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return self.text
```

此处定义了Topic类。它继承了Model-Djanjo中一个定义了模型基本功能的类。Topic类有两个属性：text和date_added。

text属性一个Charfield--由字符和文本组成的数据。用于储存主题名，长度为200字符。

date_added是一个DateTimeField-记录日期及时间的数据。传递了实参（auto_now_add=True）。每当用户创建新主题之后，Djanjo会将这个属性自动设置为当前日期时间。

*参考Django model field rederence了解可在模型中使用的字段。*   

Django调用方法`__str__()`来显示模型的简单表示，这里编写方法，返回储存在属性text中的字符串。



### 激活模型

要使用模型，必须Django将应用程序包含到项目中。为此，打开settings.py，找到INSTALLED_APPS：

```python
...

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
]

...
```

这是一个元组，告诉Django项目由哪些应用程序组成。我们需要添加`own_notes`到这个元组：

```python
...

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'own_notes',
]

...
```

接下来需要让Django修改数据库，使其能够储存与Topic相关的信息。

```shell
[python@localhost ~]$ python manage.py makemigrations own_notes
Migrations for 'own_notes':
  own_notes/migrations/0001_initial.py
    - Create model Topic
#命令makemigrations让Django确定如何更改数据库。输出表名创建了0001_initial.py的迁移文件。

[python@localhost ~]$ python manage.py migrate
Operations to perform:
  Apply all migrations: admin, auth, contenttypes, own_notes, sessions
Running migrations:
  Applying own_notes.0001_initial... OK
#通过此命令将应用这种迁移，让Django修改数据库。
```



### 管理网站

为应用程序定义模型时，Django提供的管理网站（admin site）让你能够轻松地处理模型。



#### 创建超级用户

```shell
[python@localhost ~]$ ls
db.sqlite3  manage.py  own_note  own_notes
[python@localhost ~]$ python manage.py createsuperuser
Username (leave blank to use 'python'): fu13
Email address: 313346216@qq.com
Password: 
Password (again): 
Superuser created successfully.
```

#### 向管理网站注册模型

Django自动在管理网站中添加了一些模型，如user，group，但对于我们创建的模型，必须进行手工注册。

我们创建应用程序own_notes时，Django在models.py所在的目录中创建了一个admin.py。

- `admin.py`

```python
from django.contrib import admin

# Register your models here.
```

为向管理网站注册Topic，需要将topic引用。

- `admin.py`

```python
from django.contrib import admin

from own_notes.models import Topic

admin.site.register(Topic)
```

此时使用超级用户账户访问管理网站：`127.0.0.1:8000/admin`。就可以添加用户、组，还可以管理与Topic模型相关的数据。

#### 添加主题

在管理网站注册Topic后，可以开始添加主题。

在页面单机Topic进入主题页面。单击add，可以看见刚创建的表单。

在输入框中输入`linux` ，单击save，这将返回主题管理页面，其中包含了刚创建的linux主题。

同样的方法，添加一个名字叫`python`的主题。



#### 定义模型条目（entry）

要记录与linux和python相关的笔记。需要为用户在笔记中添加条目定义模型。每个条目都与特定主题关联。这种关系是多对一关系。

* `models.py`

```python
from django.db import models

class Topic(models.Model):
    ...
		return self.text

class Entry(models.Model):
    topic = models.ForeignKey(Topic,on_delete=models.CASCADE)
    text = models.TextField()
    date_added = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name_plural = 'entries'

    def __str__(self):
        return self.text[:50] + '...'
```

与Topic一样，Entry也继承了Django基类Model。第一个属性topic是一个外键实例。连接到了Topic上，每次主题创建是，都会为它分配一个键（或ID）。

text属性，是一个TextField实例，这种字段不需要长度限制。

date_added依旧是时间属性。

然后嵌套了一个Meta的类，用于管理模型的额外信息。在这里，我们可以设置一个特殊属性。让Django在需要时，通过`Entries`来显示多个条目。如果没有这个类，Django会使用`Entrys`来表示多个条目。

最后的`__str__()`方法告诉Django，需要显示那些信息。由于条目可能很长，所有只显示前50个字符。还添加了省略号，指出显示的非整个条目。



### 迁移模型Entry

由于添加了新模型，需要再次迁移数据库。执行跟之前一样的操作。

```shell
[python@localhost ~]$ python manage.py makemigrations own_notes
Migrations for 'own_notes':
  own_notes/migrations/0002_entry.py
    - Create model Entry
[python@localhost ~]$ python manage.py migrate
Operations to perform:
  Apply all migrations: admin, auth, contenttypes, own_notes, sessions
Running migrations:
  Applying own_notes.0002_entry... OK
```



### 向管理网站注册Entry

* `admin.py`

```python
from django.contrib import admin

from own_notes.models import Topic,Entry

admin.site.register(Topic)
admin.site.register(Entry)
```

此时通过前端即可添加条目。



### Django shell

输入一些数据之后，就可以通过交互式终端会话以编程方式查看这些数据。这种交互式环境称为Django shell。

```shell
[python@localhost ~]$ python manage.py shell
Python 3.6.6 (default, Aug 30 2019, 10:05:38) 
[GCC 4.8.5 20150623 (Red Hat 4.8.5-36)] on linux
Type "help", "copyright", "credits" or "license" for more information.
(InteractiveConsole)
>>> 
```

