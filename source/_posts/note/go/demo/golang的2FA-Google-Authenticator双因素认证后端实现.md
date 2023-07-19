---
title: golang的2FA-Google-Authenticator双因素认证后端实现
tags:
  - go
categories:
  - demo
abbrlink: eab36d72
date: 2021-10-14 00:00:00
updated: 2021-10-14 00:00:00
---
## 1. TOTP的概念

TOTP 的全称是”基于时间的一次性密码”(Time-based One-time Password). 它是公认的可靠解决方案,已经写入国际标准 RFC6238.

它的步骤如下.

- 第一步,用户开启双因素认证后,服务器生成一个密钥.
- 第二步：服务器提示用户扫描二维码(或者使用其他方式),把密钥保存到用户的手机.也就是说,服务器和用户的手机,现在都有了同一把密钥.
- 第三步,用户登录时,手机客户端使用这个密钥和当前时间戳,生成一个哈希,有效期默认为30秒.用户在有效期内,把这个哈希提交给服务器.(注意,密钥必须跟手机绑定.一旦用户更换手机,就必须生成全新的密钥.)
- 第四步,服务器也使用密钥和当前时间戳,生成一个哈希,跟用户提交的哈希比对.只要两者不一致,就拒绝登录.

## 2. [RFC6238](https://tools.ietf.org/html/rfc6238)

根据RFC 6238标准,供参考的实现如下：

- 生成一个任意字节的字符串密钥K,与客户端安全地共享.
- 基于T0的协商后,Unix时间从时间间隔(TI)开始计数时间步骤,TI则用于计算计数器C(默认情况下TI的数值是T0和30秒)的数值
- 协商加密哈希算法(默认为SHA-1)
- 协商密码长度(默认6位)

## 3.  示例代码

```go
package main

import (
	"crypto/hmac"
	"crypto/sha1"
	"encoding/base32"
	"encoding/binary"
	"errors"
	"fmt"
	"net/url"
	"testing"
	"time"
)

//GoogleAuthenticator2FaSha1 只实现google authenticator sha1
type GoogleAuthenticator2FaSha1 struct {
	Base32NoPaddingEncodedSecret string //The base32NoPaddingEncodedSecret parameter is an arbitrary key value encoded in Base32 according to RFC 3548. The padding specified in RFC 3548 section 2.2 is not required and should be omitted.
	ExpireSecond                 uint64 //更新周期单位秒
	Digits                       int    //数字数量
}

//otpauth://totp/ACME%20Co:john@example.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=SHA1&digits=6&period=30
const testSecret = "HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ" //base32-no-padding-encoded-string

//Totp 计算Time-based One-time Password 数字
func (m *GoogleAuthenticator2FaSha1) Totp() (code string, err error) {
	count := uint64(time.Now().Unix()) / m.ExpireSecond
	key, err := base32.StdEncoding.WithPadding(base32.NoPadding).DecodeString(m.Base32NoPaddingEncodedSecret)
	if err != nil {
		return "", errors.New("https://github.com/google/google-authenticator/wiki/Key-Uri-Format,REQUIRED: The base32NoPaddingEncodedSecret parameter is an arbitrary key value encoded in Base32 according to RFC 3548. The padding specified in RFC 3548 section 2.2 is not required and should be omitted.")
	}
	codeInt := hotp(key, count, m.Digits)
	intFormat := fmt.Sprintf("%%0%dd", m.Digits) //数字长度补零
	return fmt.Sprintf(intFormat, codeInt), nil
}

//QrString google authenticator 扫描二维码的二维码字符串
func (m *GoogleAuthenticator2FaSha1) QrString(label, issuer string) (qr string) {
	issuer = url.QueryEscape(label) //有一些小程序MFA不支持
	//规范文档 https://github.com/google/google-authenticator/wiki/Key-Uri-Format
	//otpauth://totp/ACME%20Co:john.doe@email.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=SHA1&digits=6&period=30
	return fmt.Sprintf(`otpauth://totp/%s?secret=%s&issuer=%s&algorithm=SHA1&digits=%d&period=%d`, label, m.Base32NoPaddingEncodedSecret, issuer, m.Digits, m.ExpireSecond)
}

func hotp(key []byte, counter uint64, digits int) int {
	//RFC 6238
	//只支持sha1
	h := hmac.New(sha1.New, key)
	binary.Write(h, binary.BigEndian, counter)
	sum := h.Sum(nil)
	//取sha1的最后4byte
	//0x7FFFFFFF 是long int的最大值
	//math.MaxUint32 == 2^32-1
	//& 0x7FFFFFFF == 2^31  Set the first bit of truncatedHash to zero  //remove the most significant bit
	// len(sum)-1]&0x0F 最后 像登陆 (bytes.len-4)
	//取sha1 bytes的最后4byte 转换成 uint32
	v := binary.BigEndian.Uint32(sum[sum[len(sum)-1]&0x0F:]) & 0x7FFFFFFF
	d := uint32(1)
	//取十进制的余数
	for i := 0; i < digits && i < 8; i++ {
		d *= 10
	}
	return int(v % d)
}
func TestTotp(t *testing.T) {
	g := GoogleAuthenticator2FaSha1{
		Base32NoPaddingEncodedSecret: testSecret,
		ExpireSecond:                 30,
		Digits:                       6,
	}
	totp, err := g.Totp()
	if err != nil {
		t.Error(err)
		return
	}
	t.Log(totp)
}

func TestQr(t *testing.T) {
	g := GoogleAuthenticator2FaSha1{
		Base32NoPaddingEncodedSecret: testSecret,
		ExpireSecond:                 30,
		Digits:                       6,
	}
	qrString := g.QrString("TechBlog:mojotv.cn", "Eric Zhou")
	t.Log(qrString)
}
func main() {
	//HXDMVCCCJJWSRB3HWIZR4IFUGFTMXBOZ 密码串，暂时没弄明白加密原理
	//expiresecond  刷新时间
	//digits 数字位数
	//label 使用者
	//issuer 颁发者
	//返回一个二维码地址
	a := GoogleAuthenticator2FaSha1{"HXDMVCCCJJWSRB3HWIZR4IFUGFTMXBOZ", 30, 6}
	b := a.QrString("fushisanlang", "dao.server")
	fmt.Println(b)
	escapeUrl := url.QueryEscape(b)
	fmt.Println("https://api.pwmqr.com/qrcode/create/?url=" + escapeUrl)
}

```

