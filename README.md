# wrtbox

OpenWrt 25.12 / ImmortalWrt 25.12 的 sing-box APK Feed。

## 安装 Feed

### Pages

```sh
wget -O - https://wrtbox.pages.dev/feed.sh \
  | ash -s -- stable auto
```

### GitHub

```sh
wget -O - https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh \
  | ash -s -- stable auto
```

### gh-proxy

```sh
wget -O - \
  https://gh-proxy.com/https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh \
  | ash -s -- stable auto
```

安装 beta：把 `stable` 改为 `beta`。

## Feed 模式

自动选择：

```sh
... | ash -s -- stable auto
```

强制使用服务器：

```sh
... | ash -s -- stable server
```

强制使用 GitHub：

```sh
... | ash -s -- stable direct
```

脚本只修改 `customfeeds.list` 中属于 wrtbox 的行，其他 Feed 不动。

## 安装与升级

安装：

```sh
apk add sing-box
```

升级：

```sh
apk upgrade sing-box
```

也可以在 LuCI 软件包页面点击“更新列表”和“安装/升级”。

## 指定版本

归档 Feed：

```text
https://wrtbox-archive.pages.dev/openwrt-25.12/1.14.3/aarch64_generic/packages.adb
```

指定安装：

```sh
apk add sing-box=1.14.3-r0
```

回到最新版本：

```sh
apk upgrade sing-box
```

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

将新的服务器地址设置为 GitHub Actions Secret：

```text
WRTBOX_SERVER
```

Actions 还需要以下 Secrets：

```text
APK_SIGN_PRIVATE_KEY
CLOUDFLARE_API_TOKEN
CLOUDFLARE_ACCOUNT_ID
WRTBOX_SSH_PRIVATE_KEY_B64
```
