---
title: hexo Context Dump Ends 报错处理
date: 2019-1-16
updated: 2019-1-17
tags:
  - hexo
categories:
  - note
abbrlink: bb7078cb
---

```
   =====             Context Dump Ends            =====
   at formatNunjucksError (D:\blog\node_modules\hexo\lib\extend\tag.js:99:13)
   at D:\blog\node_modules\hexo\lib\extend\tag.js:121:34
   at tryCatcher (D:\blog\node_modules\bluebird\js\release\util.js:16:23)
   at Promise._settlePromiseFromHandler (D:\blog\node_modules\bluebird\js\release\promise.js:547:31)
   at Promise._settlePromise (D:\blog\node_modules\bluebird\js\release\promise.js:604:18)
   at Promise._settlePromise0 (D:\blog\node_modules\bluebird\js\release\promise.js:649:10)
   at Promise._settlePromises (D:\blog\node_modules\bluebird\js\release\promise.js:725:18)
   at _drainQueueStep (D:\blog\node_modules\bluebird\js\release\async.js:93:12)
   at _drainQueue (D:\blog\node_modules\bluebird\js\release\async.js:86:9)
   at Async._drainQueues (D:\blog\node_modules\bluebird\js\release\async.js:102:5)
   at Immediate.Async.drainQueues [as _onImmediate] (D:\blog\node_modules\bluebird\js\release\async.js:15:14)
   at processImmediate (internal/timers.js:461:21)

```



使用md编写hexo博客时，报了这个错误。

是因为使用了 { { } }   { % % } 相关的标签引起的。

hexo 的文章渲染使用的是 `Nunjucks` ，因为在使用`mathjax`公式，造成了`{ {`重叠，而它会在生成文章时将那几个大括号识别成自己的语法，这样就会报错。

用空格隔开就好；