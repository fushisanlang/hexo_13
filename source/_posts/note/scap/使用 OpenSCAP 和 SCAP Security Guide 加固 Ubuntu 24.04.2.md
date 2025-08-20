---
title: 使用 OpenSCAP 和 SCAP Security Guide 加固 Ubuntu 24.04.2
tags:
  - linux
  - OpenSCAP
  - scap
categories:
  - note
abbrlink: '8e130763'
date: 2025-08-20 00:00:00
---

# 使用 OpenSCAP 和 SCAP Security Guide 加固 Ubuntu 24.04.2 

> 参考原文：*[使用 OpenSCAP 和 SCAP Security Guide 加固Ubuntu 24.04.2 (Noble Numbat)](https://www.qixinlee.com/archives/439)*

---

## TL;DR（最短路径）
1. 安装工具：
   ```bash
   sudo apt update && sudo apt install -y openscap-scanner
   oscap --version   # 确认安装（例：OpenSCAP command line tool (oscap) 1.3.9）
   ```
2. 下载 SSG 内容并解压：
   ```bash
   wget https://github.com/ComplianceAsCode/content/releases/download/v0.1.76/scap-security-guide-0.1.76.zip
   unzip scap-security-guide-0.1.76.zip && cd scap-security-guide-0.1.76
   ```
3. 查看 Ubuntu 24.04 的数据流（DS）文件并枚举可用配置：
   ```bash
   oscap info ssg-ubuntu2404-ds.xml
   ```
4. 评估（示例：CIS Level 1 Server）：
   ```bash
   oscap xccdf eval      --profile xccdf_org.ssgproject.content_profile_cis_level1_server      --results scan-results.xml      --report report.html      ssg-ubuntu2404-ds.xml
   ```
5. 生成并审查修复脚本：
   ```bash
   oscap xccdf generate fix      --profile xccdf_org.ssgproject.content_profile_cis_level1_server      --output remediation.sh      ssg-ubuntu2404-ds.xml

   less remediation.sh   # **务必先审查** 再执行
   ```
6. 应用修复并复查：
   ```bash
   bash remediation.sh
   oscap xccdf eval      --profile xccdf_org.ssgproject.content_profile_cis_level1_server      --results scan-results-after.xml      --report report-after.html      ssg-ubuntu2404-ds.xml
   ```

---

## 背景与角色分工
- **OpenSCAP**：执行扫描与评估，生成报告/修复内容（遵循 SCAP 标准：XCCDF、OVAL、CPE 等）。
- **SCAP Security Guide (SSG)**：提供各系统与标准的**规则集**与**数据流**（CIS、DISA STIG、PCI‑DSS 等）。
- **配合关系**：OpenSCAP = 引擎；SSG = 规则/内容。

---

## 环境准备
```bash
sudo apt update
sudo apt install -y openscap-scanner
oscap --version
```

---

## 获取并使用 SSG 内容
```bash
wget https://github.com/ComplianceAsCode/content/releases/download/v0.1.76/scap-security-guide-0.1.76.zip
unzip scap-security-guide-0.1.76.zip
cd scap-security-guide-0.1.76
```

常见文件：
- `ssg-ubuntu2404-ds.xml`：Ubuntu 24.04 的数据流（含规则、OVAL、修复等）。

查看内容与可用配置文件（profiles）：
```bash
oscap info ssg-ubuntu2404-ds.xml
```

---

## 常用配置（Profiles）
- **CIS Level 1 Server**：`xccdf_org.ssgproject.content_profile_cis_level1_server`
- **CIS Level 1 Workstation**：`xccdf_org.ssgproject.content_profile_cis_level1_workstation`
- **CIS Level 2 Server**：`xccdf_org.ssgproject.content_profile_cis_level2_server`
- **CIS Level 2 Workstation**：`xccdf_org.ssgproject.content_profile_cis_level2_workstation`

> 选择建议：
> - 服务器：`cis_level1_server`（基础安全）或 `cis_level2_server`（更严格）
> - 工作站：`cis_level1_workstation` 或 `cis_level2_workstation`

---

## 扫描与报告（以 Level 1 Server 为例）
```bash
oscap xccdf eval   --profile xccdf_org.ssgproject.content_profile_cis_level1_server   --results scan-results.xml   --report report.html   ssg-ubuntu2404-ds.xml
```
输出物：
- `scan-results.xml`：机器可读的详细结果
- `report.html`：可视化报告（用浏览器打开）

---

## 生成与应用修复
生成修复脚本：
```bash
oscap xccdf generate fix   --profile xccdf_org.ssgproject.content_profile_cis_level1_server   --output remediation.sh   ssg-ubuntu2404-ds.xml
```
执行前：
```bash
less remediation.sh   # 根据自身业务/合规要求审查与定制
```
执行与复查：
```bash
bash remediation.sh
oscap xccdf eval   --profile xccdf_org.ssgproject.content_profile_cis_level1_server   --results scan-results-after.xml   --report report-after.html   ssg-ubuntu2404-ds.xml
```

---

## 实战清单（Checklist）
- [ ] 在非生产环境先演练一遍
- [ ] 备份关键配置与数据（如 `/etc`、审计策略、服务配置）
- [ ] 与运维/安全/合规沟通变更窗口
- [ ] `remediation.sh` 执行前逐项审查并按需裁剪
- [ ] 修复后复测并归档 `report.html` 与差异

---

## 常见问题与提示
- **命令报错/规则失败**：
  - 优先阅读 `report.html` 与 `scan-results.xml` 的详细说明；
  - 有些规则需要人工确认或特定上下文，按需在 `remediation.sh` 里定制；
  - 逐步应用（分组执行）降低风险。
- **Level 2 更严格**：
  - 可能影响可用性，务必结合业务容忍度和合规目标评估。
- **报表留痕**：
  - 将 `report.html` 与脚本版本、时间戳归档，便于审计与复盘。

---

## 一键示例（Server / Level 1）
```bash
# 评估
oscap xccdf eval   --profile xccdf_org.ssgproject.content_profile_cis_level1_server   --results scan-results.xml   --report report.html   ssg-ubuntu2404-ds.xml

# 生成修复
oscap xccdf generate fix   --profile xccdf_org.ssgproject.content_profile_cis_level1_server   --output remediation.sh   ssg-ubuntu2404-ds.xml

# 审查 & 执行
less remediation.sh
bash remediation.sh

# 复查
oscap xccdf eval   --profile xccdf_org.ssgproject.content_profile_cis_level1_server   --results scan-results-after.xml   --report report-after.html   ssg-ubuntu2404-ds.xml
```

---

> 注：上述命令基于 Ubuntu 24.04（Noble Numbat）与 SSG v0.1.76，若后续版本更新，请以新版本数据流（`ssg-ubuntu2404-ds.xml`）为准，并留意变更说明。
