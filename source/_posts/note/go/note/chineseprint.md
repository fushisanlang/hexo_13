---
title: 中文输出
tags:
  - go
  - note
categories:
  - note
abbrlink: 6e9056b1
date: 2023-12-28 00:00:00
---  
windows下，cmd对中文指出不好，通过fmt包输出的中文会乱码。   
可以使用以下demo，对cmd的语言预配置。   
但是目前依旧存在跨平台的问题，windows平台才能使用。所以实际使用中可能需要不同的入口文件对应不同的操作系统。   
```golang
package main

import (
	"fmt"
	"runtime"
	"syscall"

)

func main() {
	// 判断操作系统类型
	if runtime.GOOS == "windows" {
		// Windows API函数声明
		kernel32           := syscall.NewLazyDLL("kernel32.dll")
		setConsoleOutputCP := kernel32.NewProc("SetConsoleOutputCP")
		setConsoleOutputCP.Call(uintptr(936))
	}

	// 输出中文测试
	fmt.Println("中文输出测试")
}

```