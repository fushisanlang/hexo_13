---
title: iframe使用
tags:
  - w3c
  - html
  - js
  - demo
categories:
  - note
abbrlink: 1c95b3fb
date: 2021-10-21 00:00:00
updated: 2021-10-21 00:00:00
---

# 分解示例
```html
<!-- 可以下载ul标签 li标签里，用于选择 -->
<a class="nav-link h4 active" aria-current="page" href="http://127.0.0.1:5000/s1" target="test">链接1</a>
<a class="nav-link h4 active" aria-current="page" href="http://127.0.0.1:5000/s2" target="test">链接2</a>

<!-- 上边的a标签target要与iframe标签的name标签一致 -->
<iframe name="test" id="test" class="embed-responsive-item" src="http://127.0.0.1:5000/s" style="width: 100%;" ></iframe>

```

# 完整示例
```html

<div class="container-fluid">
  <div class="row">
    <nav id="sidebarMenu" class="col-md-3 col-lg-2 d-md-block bg-light sidebar collapse">
      <div class="position-sticky pt-3">
        <ul class="nav flex-column">
         
          {% for paragraphs in paragraphsList %}
          <li class="nav-item h4">
            <a class="nav-link h4 active" aria-current="page" href="http://127.0.0.1:5000/s" target="test">
              <!--span data-feather="home"></span-->
              {{ paragraphs }}
             </a>
          </li>
          {% endfor %}
        </ul>

       
      </div>
    </nav>

    <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4"> 
        <iframe name="test" id="test" class="embed-responsive-item" src="http://127.0.0.1:5000/s" style="width: 100%;" ></iframe>

 

    </main>
  </div>
</div>
```


# 自动调节高度的js
```JavaScript
< script language = "JavaScript" >
//输入你希望根据页面高度自动调整高度的iframe的名称的列表
//用逗号把每个iframe的ID分隔. 例如: ["myframe1", "myframe2"]，可以只有一个窗体，则不用逗号。
//定义iframe的ID
var iframeids = ["test"];
//如果用户的浏览器不支持iframe是否将iframe隐藏 yes 表示隐藏，no表示不隐藏
var iframehide = "yes";
function dyniframesize() {
    var dyniframe = new Array() for (i = 0; i < iframeids.length; i++) {
        if (document.getElementById) {
            //自动调整iframe高度
            dyniframe[dyniframe.length] = document.getElementById(iframeids[i]);
            if (dyniframe[i] && !window.opera) {
                dyniframe[i].style.display = "block";
                if (dyniframe[i].contentDocument && dyniframe[i].contentDocument.body.offsetHeight) //如果用户的浏览器是NetScape
                dyniframe[i].height = dyniframe[i].contentDocument.body.offsetHeight;
                else if (dyniframe[i].Document && dyniframe[i].Document.body.scrollHeight) //如果用户的浏览器是IE
                dyniframe[i].height = dyniframe[i].Document.body.scrollHeight;
            }
        }
        //根据设定的参数来处理不支持iframe的浏览器的显示问题
        if ((document.all || document.getElementById) && iframehide == "no") {
            var tempobj = document.all ? document.all[iframeids[i]] : document.getElementById(iframeids[i]);
            tempobj.style.display = "block";
        }
    }
}
if (window.addEventListener) window.addEventListener("load", dyniframesize, false);
else if (window.attachEvent) window.attachEvent("onload", dyniframesize);
else window.onload = dyniframesize; < /script>/
```
