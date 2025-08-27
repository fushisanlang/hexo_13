---
title: 在 Harbor 上使用 Cosign 给 Docker 镜像签名
date: 2025-8-27
tags:
  - docker
  - Cosign
categories:
  - note
abbrlink: 4ffa0d7b
---

本文介绍如何在 Harbor 私有仓库中使用 [Cosign](https://github.com/sigstore/cosign) 对 Docker 镜像进行数字签名，并提供离线验证方法，确保交付镜像的完整性和来源可信。

---

## 1. 背景

* **为什么签名？**

  * 确保客户拿到的镜像和发布镜像一致，避免中间篡改。
  * 提升交付安全性，满足安全或合规要求。
  * 客户可以在部署前自动验证镜像真实性。

* **Cosign 特点**

  * 开源，操作简单。
  * 签名存储在 OCI 兼容仓库（如 Harbor）中。
  * 支持离线签名，不依赖公有 Rekor 服务。

---

## 2. 安装 Cosign

在 Linux 上执行：

```bash
curl -sSL https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64 -o cosign
sudo mv cosign /bin
sudo chmod +x /bin/cosign
```

生成签名密钥对：

```bash
cosign generate-key-pair
```

* `cosign.key`：私钥，用于签名，需妥善保管
* `cosign.pub`：公钥，用于验证，提供给客户

---

## 3. 构建并推送镜像

以 `caddy` 镜像为例：

```bash
docker tag caddy harborpro.fuckave.net/devops/caddy:trust
docker push harborpro.fuckave.net/devops/caddy:trust
```

获取镜像 digest（唯一不可变标识）：

```bash
docker inspect --format='{{index .RepoDigests 0}}' harborpro.fuckave.net/devops/caddy:trust
```

示例输出：

```
harborpro.fuckave.net/devops/caddy@sha256:3ebdac0a04a6802fdf72da35e476866e5f34e1a717a921dff2b2561d1ce2e96e
```

---

## 4. 签名镜像

使用私钥签名，并关闭公共 Rekor 上传（内网环境推荐）：

```bash
cosign sign --key cosign.key --tlog-upload=false harborpro.fuckave.net/devops/caddy@sha256:3ebdac0a04a6802fdf72da35e476866e5f34e1a717a921dff2b2561d1ce2e96e
```

签名完成后，签名数据会存储在 Harbor 仓库中。

---

## 5. 离线验证签名

在客户或内网环境中验证镜像签名，不依赖公有 Rekor：

```bash
export COSIGN_EXPERIMENTAL=1
export COSIGN_EXPERIMENTAL_DISABLE_TUF=1

cosign verify \
  --key cosign.pub \
  --offline \
  --insecure-ignore-tlog=true \
  --private-infrastructure=true \
  harborpro.fuckave.net/devops/caddy:trust
```

验证通过后，会显示签名者、镜像 digest 等信息。

---

## 6. 常见问题

1. **权限错误 (401 Unauthorized)**

   * 执行 `docker login harborpro.fuckave.net`，使用有 push 权限的账号。

2. **tag 不存在**

   * 必须先 `docker push` 镜像，再获取 digest 进行签名。

3. **内网无法访问 Rekor/TUF 公共服务**

   * 使用 `--tlog-upload=false` 和 `--offline` 完全离线签名和验证。

---

## 7. 完整命令汇总

```bash
# 安装 cosign
curl -sSL https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64 -o cosign
sudo mv cosign /bin
sudo chmod +x /bin/cosign

# 生成密钥对
cosign generate-key-pair

# 构建并推送镜像
docker tag caddy harborpro.fuckave.net/devops/caddy:trust
docker push harborpro.fuckave.net/devops/caddy:trust

# 获取镜像 digest
docker inspect --format='{{index .RepoDigests 0}}' harborpro.fuckave.net/devops/caddy:trust

# 签名镜像
cosign sign --key cosign.key --tlog-upload=false harborpro.fuckave.net/devops/caddy@sha256:3ebdac0a04a6802fdf72da35e476866e5f34e1a717a921dff2b2561d1ce2e96e

# 离线验证签名
export COSIGN_EXPERIMENTAL=1
export COSIGN_EXPERIMENTAL_DISABLE_TUF=1

cosign verify \
  --key cosign.pub \
  --offline \
  --insecure-ignore-tlog=true \
  --private-infrastructure=true \
  harborpro.fuckave.net/devops/caddy:trust
```

