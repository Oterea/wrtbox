# wrtbox

OpenWrt 25.12 / ImmortalWrt 25.12 的 sing-box APK Feed。

下面命令只配置 Feed 并执行 `apk update`，不会安装或升级 sing-box。

## 推荐使用方式

始终优先使用 `ghproxy`：

```sh
wget -O - https://wrtbox.pages.dev/feed.sh | ash -s -- stable ghproxy
```

这条命令会配置 Feed 并执行 `apk update`，不会安装或升级 sing-box。

如果 `ghproxy` 不可用：

1. 第一次安装 sing-box，使用 `server`：

   ```sh
   wget -O - https://wrtbox.pages.dev/feed.sh | ash -s -- stable server
   apk add sing-box
   ```

2. sing-box 已经运行后更新，使用 `direct`：

   ```sh
   wget -O - https://wrtbox.pages.dev/feed.sh | ash -s -- stable direct
   apk upgrade sing-box
   ```

使用 `auto` 时，脚本会按 `ghproxy → direct（sing-box 已运行）→ server（首次安装）` 的顺序选择。

## Pages 直连

### Stable / auto

```sh
wget -O - https://wrtbox.pages.dev/feed.sh | ash -s -- stable auto
```

### Stable / server

```sh
wget -O - https://wrtbox.pages.dev/feed.sh | ash -s -- stable server
```

### Stable / direct

```sh
wget -O - https://wrtbox.pages.dev/feed.sh | ash -s -- stable direct
```

### Stable / ghproxy

```sh
wget -O - https://wrtbox.pages.dev/feed.sh | ash -s -- stable ghproxy
```

### Beta / auto

```sh
wget -O - https://wrtbox.pages.dev/feed.sh | ash -s -- beta auto
```

### Beta / server

```sh
wget -O - https://wrtbox.pages.dev/feed.sh | ash -s -- beta server
```

### Beta / direct

```sh
wget -O - https://wrtbox.pages.dev/feed.sh | ash -s -- beta direct
```

### Beta / ghproxy

```sh
wget -O - https://wrtbox.pages.dev/feed.sh | ash -s -- beta ghproxy
```

## GitHub Raw 直连

### Stable / auto

```sh
wget -O - https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh | ash -s -- stable auto
```

### Stable / server

```sh
wget -O - https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh | ash -s -- stable server
```

### Stable / direct

```sh
wget -O - https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh | ash -s -- stable direct
```

### Beta / auto

```sh
wget -O - https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh | ash -s -- beta auto
```

### Beta / server

```sh
wget -O - https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh | ash -s -- beta server
```

### Beta / direct

```sh
wget -O - https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh | ash -s -- beta direct
```

## gh-proxy

### Stable / auto

```sh
wget -O - https://gh-proxy.com/https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh | ash -s -- stable auto
```

### Stable / server

```sh
wget -O - https://gh-proxy.com/https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh | ash -s -- stable server
```

### Stable / direct

```sh
wget -O - https://gh-proxy.com/https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh | ash -s -- stable direct
```

### Beta / auto

```sh
wget -O - https://gh-proxy.com/https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh | ash -s -- beta auto
```

### Beta / server

```sh
wget -O - https://gh-proxy.com/https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh | ash -s -- beta server
```

### Beta / direct

```sh
wget -O - https://gh-proxy.com/https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh | ash -s -- beta direct
```

## 安装和升级

配置 Feed 后，单独执行：

```sh
apk add sing-box
```

升级：

```sh
apk upgrade sing-box
```

也可以在 LuCI 软件包页面点击“更新列表”，再点击安装或升级。

## 归档版本

归档 Feed：

```text
https://wrtbox-archive.pages.dev/openwrt-25.12/1.14.3/aarch64_generic/packages.adb
```

指定安装：

```sh
apk add sing-box=1.14.3-r0
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

启用或注释的 wrtbox 行都会被识别并重写。其他 Feed 不修改。

## 支持架构

```text
aarch64_generic
x86_64
```

## GitHub Actions Secrets

```text
WRTBOX_SERVER
APK_SIGN_PRIVATE_KEY
CLOUDFLARE_API_TOKEN
CLOUDFLARE_ACCOUNT_ID
WRTBOX_SSH_PRIVATE_KEY_B64
```
