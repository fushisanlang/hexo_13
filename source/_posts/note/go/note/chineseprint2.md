---
abbrlink: 742e04d5
---
---
title: golang中文输出2
tags:
  - go
  - note
categories:
  - note

date: 2024-06-04 00:00:00
---  
windows下，cmd对中文指出不好，通过fmt包输出的中文会乱码。   
可以使用以下demo，对cmd的语言预配置。

```golang
		kernel32           := syscall.NewLazyDLL("kernel32.dll")
		setConsoleOutputCP := kernel32.NewProc("SetConsoleOutputCP")
		setConsoleOutputCP.Call(uintptr(936))
```

但是目前依旧存在跨平台的问题，windows平台才能使用。所以实际使用需要调整一下编译方式。

具体方法如下：

* windows.go
```golang
//go:build windows
// +build windows
package main
import (
	"syscall"
)
func init() {
	kernel32 := syscall.NewLazyDLL("kernel32.dll")
	setConsoleOutputCP := kernel32.NewProc("SetConsoleOutputCP")
	setConsoleOutputCP.Call(uintptr(936))

}
```


* main.go
```golang
package main

import (
	"fmt"
)

func main() {
	fmt.Println("测试")
}
```

**在编译时，通过指定不同操作系统，go会自己加载所需的文件。   
即在交叉编译时，只有windows平台才会引用这个windows.go文件的init函数进行初始化。**

* 编译命令
```make
linuxBinDir="bin/linux"
winBinDir="bin/win"

build: build_win build_linux
build_win: remove_old
	mkdir -p ${winBinDir}
	GOOS=windows GOARCH=amd64 go build  -o ${winBinDir}
build_linux: remove_old
	mkdir -p ${linuxBinDir}
	go build  -o ${linuxBinDir}
remove_old:
	rm -fr ${winBinDir} ${linuxBinDir}
```