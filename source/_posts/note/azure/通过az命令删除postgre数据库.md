---
title: 通过az命令删除postgre数据库
date: 2024-7-8
tags:
  - azure
  - Azure Cli
  - postgre
categories:
  - note
---
```shell
az postgres flexible-server db delete --resource-group ${rg} --server-name ${sn} --database-name ${dbname} --yes
az postgres flexible-server db create --resource-group ${rg} --server-name ${sn} --database-name ${dbname}
```