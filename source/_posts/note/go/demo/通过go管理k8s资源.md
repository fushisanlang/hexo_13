---
title: 通过go管理k8s资源
date: 2023-12-18
tags:
  - go
  - demo
  - kubenetes
categories:
  - demo
---

# 通过go管理k8s资源
## 背景
有一个脚本需求，管理 `k8s` 的资源。因为可能需要 `web`，并且需要考虑在不同服务器上的适用性，所以没直接使用 `shell`，选择了 `go`。   
但是后来需求变了，这个就不继续了，把现有代码调整一下做个记录。

## 已实现功能
* 切换 `context`
* 查看所有 `ns`
* 查看 `ns` 的标签
* 给 `ns` 添加标签
* 查看指定 `deploy` 的 `image`
* 通过 `exe` c进入 `pod` 执行命令

## 代码 

* main.go
```go
package main

import (
	"sipg-helper/service"
)

var contextName string = "a-admin"
var nsName string = "proj"
var deployName string = "api"
var vNs string = "vns"
var ectdUser string = "root"
var ectdPass string = "pass"

func init() {

	service.AsInit(contextName)
}

func main() {
	// -----------------------------
	service.PrintHeader()
	service.PrintDelimiter()
	// -----------------------------
	service.GetAllNs()
	getInfo()
	// service.SetprojCusPool(nsName,"ttt")
	// getInfo()
}

func getInfo() {
	// -----------------------------
	service.PrintGreen(nsName, false)
	service.PrintDefault(" image tag is: ", false)
	service.PrintGreen(service.GetImage(nsName, deployName), true)
	service.PrintDelimiter()

	// -----------------------------
	service.PrintGreen(nsName, false)

	cusPool := service.GetCusNs(nsName)
	if cusPool != "" {
		service.PrintDefault(" extension pool name is: ", false)
		service.PrintGreen(cusPool, true)
	} else {
		service.PrintRed(" no extensionnsName label", true)
	}
	service.PrintDelimiter()
	// -----------------------------
	service.PrintGreen(nsName, false)
	service.PrintDefault(" tenants list : ", true)
	tenantList := service.GetTenantList(nsName)
	for _, tenantid := range tenantList {
		service.PrintYellow("\t"+tenantid, false)
		service.PrintDefault(": ", true)
		domain := service.GetTenantDomain(vNs, tenantid, ectdUser, ectdPass)
		service.PrintDefault("\t\tproj domain: ", false)
		service.PrintGreen(domain, true)
		cusExist := service.GetTenantCusExist(vNs, tenantid, ectdUser, ectdPass)
		service.PrintDefault("\t\tcus url: ", false)
		if cusExist != "" {

			service.PrintGreen(cusExist, true)

		} else {
			service.PrintRed("cus not exist", true)
		}

		service.PrintDelimiterWithTab()
		// -----------------------------
	}

}

```

* models/cus.go
```go
package models

type CusData struct {
	PublicUrl   string `json:"PublicUrl"`
	InternalUrl string `json:"InternalUrl"`
}
```

* service/beautyprint.go
```go
package service

import "fmt"


func bueatyPrint(colorCode,printString string) string {
	return "\x1b[" + colorCode + "m" + printString + "\x1b[0m"
}

func PrintRed(printString string,newLine bool) {
	printStringNew := bueatyPrint("31",printString)
	if newLine {
		fmt.Println(printStringNew)
	} else {
		fmt.Printf(printStringNew)
	}
}

func PrintGreen(printString string,newLine bool) {
	printStringNew := bueatyPrint("32",printString)
	if newLine {
		fmt.Println(printStringNew)
	} else {
		fmt.Printf(printStringNew)
	}
}

func PrintYellow(printString string,newLine bool) {
	printStringNew := bueatyPrint("33",printString)
	if newLine {
		fmt.Println(printStringNew)
	} else {
		fmt.Printf(printStringNew)
	}
}
func PrintPurple(printString string,newLine bool) {
	printStringNew := bueatyPrint("35",printString)
	if newLine {
		fmt.Println(printStringNew)
	} else {
		fmt.Printf(printStringNew)
	}
}

func PrintDefault(printString string,newLine bool) {
	printStringNew := bueatyPrint("0",printString)
	if newLine {
		fmt.Println(printStringNew)
	} else {
		fmt.Printf(printStringNew)
	}
}

func PrintDelimiter(){
	PrintDefault("------------------------------------------",true)
}
func PrintDelimiterWithTab(){
	PrintDefault("\t------------------------------------------",true)
}
func PrintHeader(){


	PrintPurple(`       .__                        .__           .__                       `,true)
	PrintPurple(`  _____|__|_____   ____           |  |__   ____ |  | ______   ___________ `,true)
	PrintPurple(` /  ___/  \____ \ / ___\   ______ |  |  \_/ __ \|  | \____ \_/ __ \_  __ \`,true)
	PrintPurple(` \___ \|  |  |_> > /_/  > /_____/ |   Y  \  ___/|  |_|  |_> >  ___/|  | \/`,true)
	PrintPurple(`/____  >__|   __/\___  /          |___|  /\___  >____/   __/ \___  >__|   `,true)
	PrintPurple(`     \/   |__|  /_____/                \/     \/     |__|        \/       `,true)
	
}
```

* service/kubeclient.go

```go
package service

import (
	"bytes"
	"os"
	"strings"
	v1 "k8s.io/api/core/v1"
	"k8s.io/client-go/kubernetes"

	"k8s.io/client-go/kubernetes/scheme"
	"k8s.io/client-go/rest"

	"k8s.io/client-go/tools/clientcmd"
	_ "k8s.io/client-go/tools/clientcmd/api"
	"k8s.io/client-go/tools/remotecommand"

)
var clientset *kubernetes.Clientset
var config *rest.Config
// GetTenantDomain 获取指定租户的自定义域名信息



func AsInit(contextStr string)  {
	kubeconfig := os.Getenv("HOME") + "/.kube/config"
	config, _= clientcmd.BuildConfigFromFlags("", kubeconfig)
	config, _= setCurrentContext(config, contextStr)
	clientset, _ = kubernetes.NewForConfig(config)
}

func setCurrentContext(config *rest.Config, contextName string) (*rest.Config, error) {
	rules := clientcmd.NewDefaultClientConfigLoadingRules()
	overrides := &clientcmd.ConfigOverrides{CurrentContext: contextName}
	kubeConfig := clientcmd.NewNonInteractiveDeferredLoadingClientConfig(rules, overrides)
	return kubeConfig.ClientConfig()
}


func ExecInPod(namespace, podName string, command []string, containerName string) (string,string,error) {


	const tty = false
	req := clientset.CoreV1().RESTClient().Post().
		Resource("pods").
		Name(podName).
		Namespace(namespace).SubResource("exec").Param("container", containerName)
	req.VersionedParams(
		&v1.PodExecOptions{
			Command: command,
			Stdin:   false,
			Stdout:  true,
			Stderr:  true,
			TTY:     tty,
		},
		scheme.ParameterCodec,
	)

	var stdout, stderr bytes.Buffer
	exec, err := remotecommand.NewSPDYExecutor(config, "POST", req.URL())
	if err != nil {
		panic(err)
	}
	err = exec.Stream(remotecommand.StreamOptions{
		Stdin:  nil,
		Stdout: &stdout,
		Stderr: &stderr,
	})
	if err != nil {
		panic(err)
	}
	
	return strings.TrimSpace(stdout.String()), strings.TrimSpace(stderr.String()), err
}


```


* service/tools.go
```go

package service

import (
	"context"
	"encoding/json"
	"regexp"
	"sipg-helper/models"
	"strings"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

func GetAllNs() {
	namespaces, err := clientset.CoreV1().Namespaces().List(context.TODO(), metav1.ListOptions{})
	if err != nil {
		panic(err.Error())
	}
	projNsRegex := regexp.MustCompile(`proj`)

	// 输出命名空间名称

	for _, ns := range namespaces.Items {
		nameStr := ns.ObjectMeta.Name
		if projNsRegex.MatchString(nameStr) {
			PrintGreen(nameStr, false)
			PrintDefault("\t", false)
		} else {
			PrintDefault(nameStr, false)
			PrintDefault("\t", false)
		}
	}
	PrintDefault("", true)
}

func GetTenantList(nsName string) []string {

	//Retrieve all tenants within a given pool.
	namespace := nsName
	labelKeyRegex := regexp.MustCompile(`[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}`)

	ns, err := clientset.CoreV1().Namespaces().Get(context.TODO(), namespace, metav1.GetOptions{})
	if err != nil {
		panic(err.Error())
	}

	var labelKeys []string
	for key := range ns.Labels {
		if labelKeyRegex.MatchString(key) {
			labelKeys = append(labelKeys, key)
		}
	}

	return labelKeys
}

func GetImage(nsName, deploymentName string) string {
	//Retrieve image tag
	deployment, err := clientset.AppsV1().Deployments(nsName).Get(context.TODO(), deploymentName, metav1.GetOptions{})
	if err != nil {
		return ""
	} else {
		image := deployment.Spec.Template.Spec.Containers[0].Image

		result := strings.Split(image, ":")

		return result[1]
	}
}
func GetTenantDomain(nsName, tenantId, user, pass string) string {

	podName := "etcd-0"     // 替换为目标Pod名称
	containerName := "etcd" // 替换为容器名称
	key := "proj_TenantContext_" + tenantId + "_CustomDomain"
	command := []string{"sh", "-c", "ETCDCTL_API=3 etcdctl --user=" + user + " --password=" + pass + " get " + key + " --print-value-only"}

	stdoutStr, _, _ := ExecInPod(nsName, podName, command, containerName)
	return stdoutStr
}

func GetTenantCusExist(nsName, tenantId, user, pass string) string {

	podName := "etcd-0"     // 替换为目标Pod名称
	containerName := "etcd" // 替换为容器名称
	key := "proj_TenantContext_" + tenantId + "_ExtensionConfig"
	command := []string{"sh", "-c", "ETCDCTL_API=3 etcdctl --user=" + user + " --password=" + pass + " get " + key + " --print-value-only"}

	stdoutStr, _, _ := ExecInPod(nsName, podName, command, containerName)
	if stdoutStr != "" {
		var data models.CusData
		err := json.Unmarshal([]byte(stdoutStr), &data)
		if err != nil {
			panic(err)
		}
		return data.PublicUrl
	} else {
		return ""
	}

}

func GetCusNs(nsName string) string {
	namespace := nsName
	specificLabelKey := "extensionnsName"
	ns, err := clientset.CoreV1().Namespaces().Get(context.TODO(), namespace, metav1.GetOptions{})
	if err != nil {
		panic(err)
	}

	specificLabelValue, found := ns.Labels[specificLabelKey]
	if found {
		return specificLabelValue
	} else {
		return ""
	}

}

func SetprojCusPool(projnsName, cusnsName string) {
	namespace := projnsName
	labelKey := "extensionnsName"
	labelValue := cusnsName
	ns, err := clientset.CoreV1().Namespaces().Get(context.TODO(), namespace, metav1.GetOptions{})
	if err != nil {
		panic(err.Error())
	}
	// 添加 Label 到 Namespace
	if ns.Labels == nil {
		ns.Labels = make(map[string]string)
	}
	ns.Labels[labelKey] = labelValue
	_, err = clientset.CoreV1().Namespaces().Update(context.TODO(), ns, metav1.UpdateOptions{})
	if err != nil {
		panic(err.Error())
	}
}

```