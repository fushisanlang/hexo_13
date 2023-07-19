---
title: test_port
date: 2020-8-22
updated: 2020-8-23
tags:
  - go
categories:
  - demo
abbrlink: '46e87703'
---

```golang
package main

import (
	"fmt"
	"net"
)

var address_str string

func main() {
	fmt.Scanln(&address_str)
	_, err := net.Dial("tcp", address_str)
	if err != nil {
		fmt.Println(address_str + " is error,check it!!!")
	}
}

```
