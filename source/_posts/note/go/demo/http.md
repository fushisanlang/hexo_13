---
title: http
date: 2020-2-18
updated: 2020-2-19
tags:
  - go
categories:
  - demo
abbrlink: 97780db2
---

```golang
package main 
import "net/http"
func main() {
	http.HandleFunc("/",hello)
	http.ListenAndServe(":8080",nil)	
}
func hello(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("hello world!"))
}
```
