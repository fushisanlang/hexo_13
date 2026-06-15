---
title: Go语言中使用SQLite数据库
date: 2026-06-15
tags:
  - go
  - sqlite
  - 数据库
categories:
  - note
---

Go 支持 sqlite 的驱动比较多，但很多不支持 database/sql 接口。支持 database/sql 的只有 `github.com/mattn/go-sqlite3`，基于 cgo 编写。

<!--more-->

## 驱动

- [mattn/go-sqlite3](https://github.com/mattn/go-sqlite3) — 支持 database/sql 接口，基于 cgo
- feyeleanor/gosqlite3 — 不支持 database/sql 接口
- phf/go-sqlite3 — 不支持 database/sql 接口

## 建表 SQL

```sql
CREATE TABLE `userinfo` (
    `uid` INTEGER PRIMARY KEY AUTOINCREMENT,
    `username` VARCHAR(64) NULL,
    `departname` VARCHAR(64) NULL,
    `created` DATE NULL
);

CREATE TABLE `userdeatail` (
    `uid` INT(10) NULL,
    `intro` TEXT NULL,
    `profile` TEXT NULL,
    PRIMARY KEY (`uid`)
);
```

## CRUD 实例

```go
package main

import (
    "database/sql"
    "fmt"
    _ "github.com/mattn/go-sqlite3"
)

func main() {
    db, err := sql.Open("sqlite3", "./foo.db")
    checkErr(err)

    // 插入数据
    stmt, err := db.Prepare("INSERT INTO userinfo(username, departname, created) values(?,?,?)")
    checkErr(err)
    res, err := stmt.Exec("astaxie", "研发部门", "2012-12-09")
    checkErr(err)
    id, err := res.LastInsertId()
    checkErr(err)
    fmt.Println(id)

    // 更新数据
    stmt, err = db.Prepare("update userinfo set username=? where uid=?")
    checkErr(err)
    res, err = stmt.Exec("astaxieupdate", id)
    affect, err := res.RowsAffected()
    checkErr(err)
    fmt.Println(affect)

    // 查询数据
    rows, err := db.Query("SELECT * FROM userinfo")
    checkErr(err)
    for rows.Next() {
        var uid int
        var username string
        var department string
        var created string
        err = rows.Scan(&uid, &username, &department, &created)
        checkErr(err)
        fmt.Println(uid, username, department, created)
    }

    // 删除数据
    stmt, err = db.Prepare("delete from userinfo where uid=?")
    checkErr(err)
    res, err = stmt.Exec(id)
    affect, err = res.RowsAffected()
    checkErr(err)
    fmt.Println(affect)

    db.Close()
}

func checkErr(err error) {
    if err != nil {
        panic(err)
    }
}
```

> 代码结构与 MySQL 操作几乎一致，唯一改变的是导入的驱动和 `sql.Open` 的连接方式。
