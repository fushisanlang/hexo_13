---
title: django学习(4)-创建其他网页
date: 2017-11-17
updated: 2017-11-18
tags:
  - python
  - django
categories:
  - note
abbrlink: 3e6a07
---

# django学习(4)-创建其他网页

### 模板继承

* 父模板
  * `own_notes/templates/own_notes/base.html`

```html
<p>
<a href="{% url 'own_notes:index' %}">Own notes</a>
</p>

{% block content %}{% endblock content %}
```

 `{ % % }` 是模板标签。生成要在网页中显示的信息。在这个实例中，`{ % url 'own_notes:index' % }`生成一个URL，该URL与 `own_notes/urls.py` 中定义的名为 `index` 的url匹配。

在这个实例中，own_notes是一个命名空间，而index是该命名空间中的一个独特的URL模式。

后边的代码定义了一对块标签。这个块名为content，是一个占位符。其中包含的信息将由子模板指定。

子模板并非必须定义父模板的每个块，因此父模板中可以使用任意多个块来预留空间，子模板根据需要定义相应数量的块。
<!--more-->


* 子模板
  * `own_notes/templates/own_notes/index.html`

```python
{% extends "own_notes/base.html" %}

{% block content %}
<p> hello 13 </p>
{% endblock content %}
```


