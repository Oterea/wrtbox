# wrtbox

为 OpenWrt 25.12 / ImmortalWrt 25.12 提供 sing-box 官方 OpenWrt APK 的签名 Feed。

GitHub Actions 下载官方 APK，使用 wrtbox 的 APK 私钥重新签名，然后生成两种下载路径：

- `server`：从国内服务器 `43.142.80.44` 下载 APK；
- `direct`：从 GitHub Release 直接下载 APK。

APK 本身不重新编译，Feed 也不使用 `--allow-untrusted`。

## 目录

- [快速使用](#快速使用)
- [Feed 地址](#feed-地址)
- [脚本参数](#脚本参数)
- [安装与升级](#安装与升级)
- [归档版本](#归档版本)
- [Action 流程](#action-流程)
- [服务器迁移](#服务器迁移)
- [支持范围](#支持范围)
- [安全说明](#安全说明)

## 快速使用

### Pages 直连获取脚本

```sh
wget -O - https://wrtbox.pages.dev/feed.sh \
  | ash -s -- stable auto
```

### GitHub 直连获取脚本

```sh
wget -O - https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh \
  | ash -s -- stable auto
```

### 通过 gh-proxy 获取脚本

```sh
wget -O - \
  https://gh-proxy.com/https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh \
  | ash -s -- stable auto
```

三条命令运行的是同一个仓库脚本。Pages 和 GitHub 都提供脚本副本，使用哪条命令由当前网络情况决定。

## Feed 地址

Feed 索引和公钥部署在 wrtbox Pages：

```text
https://wrtbox.pages.dev/openwrt-25.12/<channel>/<mode>/<arch>/packages.adb
```

参数取值：

```text
channel: stable 或 beta
mode:    server 或 direct
arch:    aarch64_generic 或 x86_64
```

例如：

```text
https://wrtbox.pages.dev/openwrt-25.12/stable/server/aarch64_generic/packages.adb
https://wrtbox.pages.dev/openwrt-25.12/stable/direct/aarch64_generic/packages.adb
```

`server` 索引中的 APK 地址指向国内服务器：

```text
http://43.142.80.44/stable/sing-box_<version>_openwrt_<arch>.apk
```

`direct` 索引中的 APK 地址指向 GitHub Release：

```text
https://github.com/Oterea/wrtbox/releases/download/<tag>/sing-box_<version>_openwrt_<arch>.apk
```

## 脚本参数

脚本位于：

```text
scripts/feed.sh
```

格式：

```text
feed.sh <channel> <mode>
```

### channel

```text
stable  最新稳定版
beta    最新官方 prerelease，可能是 alpha、beta 或 release candidate
```

### mode

```text
auto    自动选择
server  强制使用国内服务器
direct  强制使用 GitHub Release
```

`auto` 的逻辑：

1. 检查 `sing-box` 是否正在运行；
2. 未运行时选择 `server`；
3. 正在运行时测试 GitHub；
4. GitHub 可访问则选择 `direct`；
5. GitHub 不可访问则回退到 `server`。

脚本最后会执行：

```sh
apk update
```

脚本只切换 Feed 和更新索引，不会自动安装或升级 sing-box。

## 安装与升级

### 首次安装

首次安装通常没有 sing-box 进程，因此推荐使用 `auto`：

```sh
wget -O - https://wrtbox.pages.dev/feed.sh \
  | ash -s -- stable auto
apk add sing-box
```

也可以在 LuCI 的“软件包”页面中更新列表，然后点击安装。

### 升级

先重新运行一次脚本，使 Feed 根据当前网络状态切换：

```sh
wget -O - https://wrtbox.pages.dev/feed.sh \
  | ash -s -- stable auto
```

命令行升级：

```sh
apk upgrade sing-box
```

或者在 LuCI 软件包页面点击“更新列表”和“升级”。LuCI 的升级按钮执行的也是：

```sh
apk upgrade sing-box
```

### 强制指定下载路径

强制国内服务器：

```sh
wget -O - https://wrtbox.pages.dev/feed.sh \
  | ash -s -- stable server
```

强制 GitHub 直连：

```sh
wget -O - https://wrtbox.pages.dev/feed.sh \
  | ash -s -- stable direct
```

### Feed 文件修改范围

脚本只处理 `customfeeds.list` 中属于 wrtbox 的行：

```text
wrtbox.pages.dev
wrtbox.czuouo.workers.dev
```

它能识别启用和被注释的行，例如：

```text
https://wrtbox.pages.dev/...
# https://wrtbox.pages.dev/...
```

脚本会删除这些旧的 wrtbox 行，再写入当前选择的一个 Feed。以下内容不会修改：

```text
momomomo.pages.dev
wrtbox-archive.pages.dev
其他自定义 Feed
```

## 归档版本

归档 Feed 独立部署在：

```text
https://wrtbox-archive.pages.dev
```

1.14.3 的 aarch64 Feed：

```text
https://wrtbox-archive.pages.dev/openwrt-25.12/1.14.3/aarch64_generic/packages.adb
```

添加归档 Feed 后，可以精确安装：

```sh
apk add sing-box=1.14.3-r0
```

升级回 stable：

```sh
apk upgrade sing-box
```

归档 Feed 不参与 `auto/server/direct` 切换。

## Action 流程

每日 Action 的主要步骤：

1. 获取官方 sing-box Release；
2. 下载官方 OpenWrt APK；
3. 使用 `APK_SIGN_PRIVATE_KEY` 重新签名 APK 容器；
4. 生成 `server` Feed 索引；
5. 生成 `direct` Feed 索引；
6. 将 server APK 上传到国内服务器；
7. 将签名 APK 上传到 GitHub Release；
8. 将索引、公钥和 `feed.sh` 部署到 Pages。

官方 APK 内容不重新编译。`musl` 只属于官方 tar.gz 二进制的构建变体，本 Feed 直接使用官方 OpenWrt APK，不需要自行选择 musl 二进制。

当前默认构建架构：

```text
aarch64_generic
x86_64
```

## 服务器迁移

迁移脚本：

```text
scripts/setup-server.sh
```

它会在新的 Ubuntu 服务器上配置 Nginx、rsync 和：

```text
/srv/wrtbox/stable
/srv/wrtbox/beta
```

执行示例：

```sh
chmod +x scripts/setup-server.sh
ssh-keygen -t ed25519 -f ~/.ssh/wrtbox-actions -N ''
scripts/setup-server.sh NEW_SERVER_IP ubuntu ~/.ssh/wrtbox-actions.pub
```

设置 GitHub Actions 私钥：

```sh
base64 < ~/.ssh/wrtbox-actions | tr -d '\n' | \
  gh secret set WRTBOX_SSH_PRIVATE_KEY_B64 --repo Oterea/wrtbox
```

然后修改 `.github/workflows/update.yml` 顶部的 `WRTBOX_SERVER`，提交并推送，再手动触发 Action。

## 支持范围

- OpenWrt 25.12；
- ImmortalWrt 25.12；
- `aarch64_generic`；
- `x86_64`；
- APK 包管理器。

OpenWrt 24.10 使用 opkg/IPK，不在当前 Feed 范围内。

## 安全说明

仓库中只保存公开的脚本、Workflow 和公钥。以下内容必须保存在 GitHub Actions Secrets 中：

```text
APK_SIGN_PRIVATE_KEY
CLOUDFLARE_API_TOKEN
CLOUDFLARE_ACCOUNT_ID
WRTBOX_SSH_PRIVATE_KEY_B64
```

APK 的签名私钥不能提交到仓库。
