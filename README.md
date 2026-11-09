# wrtbox

OpenWrt 25.12 / ImmortalWrt 25.12 的 sing-box APK Feed。

下面的 Feed 配置命令只会写入 Feed 并执行 `apk update`，不会安装、升级或降级 sing-box。

## 目录

- [推荐使用顺序](#推荐使用顺序)
- [获取 Feed](#获取-feed)
  - [Pages 直连](#pages-直连)
  - [GitHub Raw 直连](#github-raw-直连)
  - [gh-proxy 获取脚本](#gh-proxy-获取脚本)
- [安装、升级和降级](#安装升级和降级)
- [常用命令](#常用命令)
- [脚本行为](#脚本行为)
- [支持架构](#支持架构)
- [GitHub Actions Secrets](#github-actions-secrets)

## 推荐使用顺序

始终优先使用 `ghproxy`：

```sh
wget -O - https://wrtbox.pages.dev/feed.sh | ash -s -- stable ghproxy
```

这条命令会配置 `ghproxy` Feed 并执行 `apk update`，不会安装或升级 sing-box。

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

使用 `auto` 时，脚本会按以下顺序选择：

```text
ghproxy → direct（sing-box 已运行）→ server（首次安装）
```

## 获取 Feed

Feed 脚本的来源有三种，三种方式执行的脚本功能相同。命令最后的 `stable` 或 `beta` 选择 sing-box 发布频道，`auto`、`server`、`ghproxy`、`direct` 选择 APK 下载来源。

### Pages 直连

#### Stable

- `auto`

  ```sh
  wget -O - https://wrtbox.pages.dev/feed.sh | ash -s -- stable auto
  ```

- `server`

  ```sh
  wget -O - https://wrtbox.pages.dev/feed.sh | ash -s -- stable server
  ```

- `ghproxy`

  ```sh
  wget -O - https://wrtbox.pages.dev/feed.sh | ash -s -- stable ghproxy
  ```

- `direct`

  ```sh
  wget -O - https://wrtbox.pages.dev/feed.sh | ash -s -- stable direct
  ```

#### Beta

- `auto`

  ```sh
  wget -O - https://wrtbox.pages.dev/feed.sh | ash -s -- beta auto
  ```

- `server`

  ```sh
  wget -O - https://wrtbox.pages.dev/feed.sh | ash -s -- beta server
  ```

- `ghproxy`

  ```sh
  wget -O - https://wrtbox.pages.dev/feed.sh | ash -s -- beta ghproxy
  ```

- `direct`

  ```sh
  wget -O - https://wrtbox.pages.dev/feed.sh | ash -s -- beta direct
  ```

### GitHub Raw 直连

#### Stable

- `auto`

  ```sh
  wget -O - https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh | ash -s -- stable auto
  ```

- `server`

  ```sh
  wget -O - https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh | ash -s -- stable server
  ```

- `ghproxy`

  ```sh
  wget -O - https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh | ash -s -- stable ghproxy
  ```

- `direct`

  ```sh
  wget -O - https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh | ash -s -- stable direct
  ```

#### Beta

- `auto`

  ```sh
  wget -O - https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh | ash -s -- beta auto
  ```

- `server`

  ```sh
  wget -O - https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh | ash -s -- beta server
  ```

- `ghproxy`

  ```sh
  wget -O - https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh | ash -s -- beta ghproxy
  ```

- `direct`

  ```sh
  wget -O - https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh | ash -s -- beta direct
  ```

### gh-proxy 获取脚本

这里的 `gh-proxy.com` 只用于获取 `feed.sh`；脚本执行后，APK 下载来源仍由最后的 `auto`、`server`、`ghproxy` 或 `direct` 参数决定。

#### Stable

- `auto`

  ```sh
  wget -O - https://gh-proxy.com/https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh | ash -s -- stable auto
  ```

- `server`

  ```sh
  wget -O - https://gh-proxy.com/https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh | ash -s -- stable server
  ```

- `ghproxy`

  ```sh
  wget -O - https://gh-proxy.com/https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh | ash -s -- stable ghproxy
  ```

- `direct`

  ```sh
  wget -O - https://gh-proxy.com/https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh | ash -s -- stable direct
  ```

#### Beta

- `auto`

  ```sh
  wget -O - https://gh-proxy.com/https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh | ash -s -- beta auto
  ```

- `server`

  ```sh
  wget -O - https://gh-proxy.com/https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh | ash -s -- beta server
  ```

- `ghproxy`

  ```sh
  wget -O - https://gh-proxy.com/https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh | ash -s -- beta ghproxy
  ```

- `direct`

  ```sh
  wget -O - https://gh-proxy.com/https://raw.githubusercontent.com/Oterea/wrtbox/main/scripts/feed.sh | ash -s -- beta direct
  ```

## 安装、升级和降级

配置 Feed 后，单独执行安装或升级命令。

安装或解除版本约束：

```sh
apk add sing-box
```

升级：

```sh
apk upgrade sing-box
```

降级到归档版本：

```sh
apk add sing-box=1.14.3-r0
```

### 注意事项：从归档版本恢复升级

安装指定版本后，`sing-box` 会保留版本约束。之后如果要升级到最新版，先执行下面的命令解除约束：

```sh
apk add sing-box
```

然后再执行：

```sh
apk upgrade sing-box
```

也可以在 LuCI 软件包页面点击“更新列表”，再点击安装或升级。

## 常用命令

更新所有 Feed 索引：

```sh
apk update
```

查看 sing-box 当前安装版本和可用版本：

```sh
apk policy sing-box
```

查看已安装的 sing-box 包：

```sh
apk list -I 'sing-box*'
```

查看 sing-box 详细信息：

```sh
apk info -a sing-box
```

模拟升级，不修改系统：

```sh
apk upgrade --simulate -v sing-box
```

查看当前启用的 Feed：

```sh
cat /etc/apk/repositories.d/customfeeds.list
```

查看 sing-box 的版本约束：

```sh
grep -n 'sing-box' /etc/apk/world
```

查看 APK 下载过程：

```sh
apk fetch -vv -o /tmp/apk-test sing-box
```

## 归档版本

归档 Feed：

```text
https://wrtbox-archive.pages.dev/openwrt-25.12/1.14.3/aarch64_generic/packages.adb
```

指定安装：

```sh
apk add sing-box=1.14.3-r0
```

安装指定版本后，如需恢复升级，请先按[注意事项](#注意事项从归档版本恢复升级)解除版本约束。

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

启用或注释的 wrtbox 行都会被识别并重写，其他 Feed 不修改。

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
