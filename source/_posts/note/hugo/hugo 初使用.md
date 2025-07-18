---
title: hugo 初使用
tags:
  - blog
  - hugo
categories:
  - note
abbrlink: 2621e7cd
date: 2025-07-18 00:00:00
---
#hugo 初使用

本文记录我如何使用 Hugo 创建博客，并在其中通过 JavaScript 接口动态加载数据的完整流程，包括安装、主题设置、Nginx 配置和最终实现一个调用外部 API 的文章效果。

## 1. 安装 Hugo

我使用的是 Hugo 的 extended 版本：

```bash
wget https://github.com/gohugoio/hugo/releases/download/v0.148.1/hugo_extended_0.148.1_linux-amd64.deb
sudo dpkg -i hugo_extended_0.148.1_linux-amd64.deb
验证版本：


hugo version
# 输出示例：hugo v0.148.1+extended linux/amd64 ...
```

## 2. 创建 Hugo 项目并配置主题
```bash
hugo new site hugo-demo
cd hugo-demo
git init
git submodule add https://github.com/theNewDynamic/gohugo-theme-ananke.git themes/ananke
echo "theme = 'ananke'" >> hugo.toml
```

## 3. 测试运行

```bash
hugo server --bind 0.0.0.0 --baseURL http://10.1.75.228:1313/ --disableFastRender
```

## 4. 创建测试文章并引入动态 JS

```bash
hugo new posts/test.md
```


* content/posts/test.md
```markdown
---
title: "测试动态 JS 数据加载"
date: 2025-07-18T10:00:00+08:00
draft: false
---

这是一个测试页面，我们将从 API 接口动态加载数据显示：

<div id="api-result">加载中...</div>

<script>
fetch("https://apis.fushisanlang.cn/apis/v1/jira/pong")
  .then(response => response.json())
  .then(data => {
    document.getElementById("api-result").innerText = "resolved_count: " + data.resolved_count;
  })
  .catch(error => {
    document.getElementById("api-result").innerText = "加载失败: " + error;
  });
</script>
```

同时需要配置 `hugo` 支持 `js` 渲染，通过更改配置文件实现。

* hugo.toml
```toml
baseURL = 'http://10.1.75.228/'
languageCode = 'en-us'
title = 'My New Hugo Site'
theme = 'ananke'

[markup]
  [markup.goldmark]
    [markup.goldmark.renderer]
      unsafe = true    ### 注意：只有 unsafe = true 设置正确时，这个 <script> 标签才会被保留并执行。
```
## 5. 小结

通过本文的流程，我们成功实现了：

* 使用 Hugo 快速创建博客

* 配置支持原生 HTML/JS

* 通过 JS 动态调用外部 API 展示数据


后续我们还计划将本地 Markdown 编写和 AI 自动清洗、整理结合起来形成一个完整的写作工作流。   
同时 `hugo` 默认支持发布到 `s3`、`gitlab page`、`github page` 等，可以一键发布。