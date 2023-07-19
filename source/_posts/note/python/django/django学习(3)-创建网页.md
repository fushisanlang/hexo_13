---
title: django学习(3)-创建网页
date: 2020-2-5
updated: 2020-2-6
tags:
  - python
  - django
categories:
  - note
abbrlink: 8a12c2be
---

# django学习(3)-创建网页

Django创建网页分为三个阶段：

* 定义URL
* 编写视图
* 编写模板



### 映射URL

* `own_note/urls.py`

```python
from django.conf.urls import url
from django.contrib import admin

urlpatterns = [
    url(r'^admin/', admin.site.urls),
]
```

前两行导入为项目和管理网站管理URL的函数和模块。

文件主体定义了`urlpatterns`。在这个针对整个模块的文件中，变量`urlpatterns`包含项目中的应用程序的url。

`url(r'^admin/', admin.site.urls)` 处的代码，包含模块`admin.site.urls`。该模块定义了可在管理网站中请求的所有URL。

我们需要包含own_notes的URL：
<!--more-->
```python
from django.conf.urls import url,include
from django.contrib import admin

urlpatterns = [
    url(r'^admin/', admin.site.urls),
    url(r'', include('own_notes.urls',namespace='own_notes')),
]
```

添加了一行代码来包括模块`own_notes.urls` ，包括实参`namespace` ，让我们能过将own_notes中的URL同项目中其他URL区分开。

下一步，在`own_notes`中创建另一个`urls.py` 。

* `own_notes/urls.py`

```python
from django.conf.urls import url

from . import views

urlpatterns = [
    url(r'^$',views.index,name='index'),
]
```



### 编写视图

* `own_note/views.py` 

```python
from django.shortcuts import render


def index(request):
    return render(request,'own_notes/index.html')
```



### 编写模板

* `own_notes/templates/own_notes/index.html`

```html
<p> own notes </p>

<p>hello world</p>
```

