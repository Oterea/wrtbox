# wrtbox

OpenWrt 25.12 / ImmortalWrt 25.12 的 sing-box APK Feed。

## Stable 安装

### Pages：自动选择

```sh
wget -O - https://wrtbox.pages.dev/feed.sh | ash -s -- stable auto
apk add sing-box
```

### Pages：强制服务器

```sh
wget -O - https://wrtbox.pages.dev/feed.sh | ash -s -- stable server
apk add sing-box
```

### Pages：强制 GitHub 直连

```sh
wget -O - https://wrtbox.pages.dev/feed.sh | ash -s -- stable direct
apk add sing-box
```

### gh-proxy：自动选择

```sh
wget -O - https://gh-proxy.com/https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh | ash -s -- stable auto
apk add sing-box
```

### gh-proxy：强制服务器

```sh
wget -O - https://gh-proxy.com/https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh | ash -s -- stable server
apk add sing-box
```

### gh-proxy：强制 GitHub 直连

```sh
wget -O - https://gh-proxy.com/https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh | ash -s -- stable direct
apk add sing-box
```

## Beta 安装

### Pages：自动选择

```sh
wget -O - https://wrtbox.pages.dev/feed.sh | ash -s -- beta auto
apk add sing-box
```

### Pages：强制服务器

```sh
wget -O - https://wrtbox.pages.dev/feed.sh | ash -s -- beta server
apk add sing-box
```

### Pages：强制 GitHub 直连

```sh
wget -O - https://wrtbox.pages.dev/feed.sh | ash -s -- beta direct
apk add sing-box
```

### gh-proxy：自动选择

```sh
wget -O - https://gh-proxy.com/https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh | ash -s -- beta auto
apk add sing-box
```

### gh-proxy：强制服务器

```sh
wget -O - https://gh-proxy.com/https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh | ash -s -- beta server
apk add sing-box
```

### gh-proxy：强制 GitHub 直连

```sh
wget -O - https://gh-proxy.com/https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh | ash -s -- beta direct
apk add sing-box
```

## 升级

Feed 切换后，命令行升级：

```sh
apk upgrade sing-box
```

LuCI：打开“软件包”，点击“更新列表”，再点击 sing-box 的“升级”。

如果只是切换下载路径，不想升级软件包，只运行对应的 Feed 命令即可；脚本会自动执行 `apk update`。

## 归档版本

归档 Feed：

```text
https://wrtbox-archive.pages.dev/openwrt-25.12/1.14.3/aarch64_generic/packages.adb
```

精确安装 1.14.3：

```sh
apk add sing-box=1.14.3-r0
```

回到最新 stable：

```sh
apk upgrade sing-box
```

## 脚本行为

脚本文件：

```text
scripts/feed.sh
```

脚本只修改 `/etc/apk/repositories.d/customfeeds.list` 中属于 wrtbox 的行：

```text
wrtbox.pages.dev
wrtbox.czuouo.workers.dev
```

已注释的 wrtbox 行也会被识别并重写。momo、归档 Feed 和其他自定义 Feed 不会修改。

## 支持架构

```text
aarch64_generic
x86_64
```

## 服务器迁移

```sh
chmod +x scripts/setup-server.sh
ssh-keygen -t ed25519 -f ~/.ssh/wrtbox-actions -N ''
scripts/setup-server.sh NEW_SERVER_IP ubuntu ~/.ssh/wrtbox-actions.pub
```

GitHub Actions Secret：

```text
WRTBOX_SERVER
APK_SIGN_PRIVATE_KEY
CLOUDFLARE_API_TOKEN
CLOUDFLARE_ACCOUNT_ID
WRTBOX_SSH_PRIVATE_KEY_B64
```
