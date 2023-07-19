---
title: minio笔记2-客户端使用
tags:
  - minio
  - 存储
  - demo
categories:
  - note
abbrlink: 81451dca
date: 2022-11-28 01:00:00
---

# minio笔记2-客户端使用

## 命令行客户端-mc
0. 官方文档
[文档地址](https://min.io/docs/minio/linux/reference/minio-mc.html)

1. 获取
```shell
wget https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x mc
mv mc /usr/local/bin/mc
```

2. 基本使用
```shell
mc alias set logbak http://120.fu:9000 logbak logbaker #配置链接信息
#实验中发现mc cp命令一直报错，不知道是哪里配置有误。如果需要使用mc客户端，可以去官网看一下说明文档
```

### python SDK - minio-py
0. 官方文档
[文档地址](https://min.io/docs/minio/linux/developers/python/minio-py.html)

### golang SDK - minio-go
0. 官方文档
[文档地址](https://min.io/docs/minio/linux/developers/go/minio-go.html)

1. 自用客户端源码
```go
package main

import (
	"context"
	"flag"
	"log"

	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"
)

func main() {
	ctx := context.Background()
	var endpoint, accessKeyID, secretAccessKey, bucketName, location, objectName, filePath string
	var useSSL int
	var Secure bool
	flag.StringVar(&endpoint, "e", "", "endpoint like 10.1.1.1:9000")
	flag.StringVar(&accessKeyID, "u", "", "accessKeyID")
	flag.StringVar(&secretAccessKey, "p", "", "secretAccessKey")
	flag.IntVar(&useSSL, "S", 0, "useSSL,0 for unuse,1 for use")
	flag.StringVar(&location, "l", "", "location")
	flag.StringVar(&bucketName, "b", "", "bucketName")
	flag.StringVar(&objectName, "o", "", "objectName on server")
	flag.StringVar(&filePath, "f", "", "filePath on local")
	flag.Parse()
	//objectName = "1/ceph详细中文文档.pdf.gz"
	//filePath = "/Users/fushisanlang/Downloads/ceph详细中文文档.pdf.gz"

	Secure = false
	if useSSL == 1 {
		Secure = true
	}

	// Initialize minio client object.
	minioClient, err := minio.New(endpoint, &minio.Options{
		Creds:  credentials.NewStaticV4(accessKeyID, secretAccessKey, ""),
		Secure: Secure,
	})
	if err != nil {
		log.Fatalln(err)
	}

	err = minioClient.MakeBucket(ctx, bucketName, minio.MakeBucketOptions{Region: location})
	if err != nil {
		// Check to see if we already own this bucket (which happens if you run this twice)
		exists, errBucketExists := minioClient.BucketExists(ctx, bucketName)
		if errBucketExists == nil && exists {
			log.Printf("We already own %s\n", bucketName)
		} else {
			log.Fatalln(err)
		}
	} else {
		log.Printf("Successfully created %s\n", bucketName)
	}

	// Upload the zip file

	contentType := "application/zip"

	// Upload the zip file with FPutObject
	info, err := minioClient.FPutObject(ctx, bucketName, objectName, filePath, minio.PutObjectOptions{ContentType: contentType})
	if err != nil {
		log.Fatalln(err)
	}

	log.Printf("Successfully uploaded %s of size %d\n", objectName, info.Size)
}

```

2. 使用示例
```shell
./upload -e 10.13.13.117:9000 -S=0 -u=logbak -p=logbaker -l 1 -b log.bak -o message -f /var/log/messages
```