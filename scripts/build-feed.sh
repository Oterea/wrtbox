#!/bin/sh
set -eu

# Feed signing is performed with the OpenWrt 25.12 SDK apk-tools binary.
# The workflow will provide APK_TOOL and SIGN_KEY. The public key is copied
# into dist/ and is safe to publish.

: "${APK_TOOL:?APK_TOOL is required}"
: "${SIGN_KEY:?SIGN_KEY is required}"
: "${ARCH:=aarch64_generic}"
: "${OPENWRT_SERIES:=25.12}"
: "${CHANNEL:=stable}"
: "${FEED_DIR:=dist/openwrt-${OPENWRT_SERIES}/${CHANNEL}/${ARCH}}"
if [ -z "${PKGNAME_SPEC:-}" ]; then
  PKGNAME_SPEC='https://gh-proxy.org/https://github.com/Oterea/wrtbox/releases/download/sing-box-v${version}/sing-box_${version}_openwrt_${arch}.apk'
fi

mkdir -p "$FEED_DIR"

# The upstream release APK is an official prebuilt binary, but its package
# signature is not trusted by OpenWrt. Re-sign the unchanged APK container with
# this feed's key so apk/LuCI can install it without --allow-untrusted.
for package in "$FEED_DIR"/*.apk; do
  [ -f "$package" ] || continue
  "$APK_TOOL" --allow-untrusted adbsign \
    --sign-key "$SIGN_KEY" \
    --reset-signatures \
    "$package"
done

"$APK_TOOL" mkndx --allow-untrusted \
  --sign-key "$SIGN_KEY" \
  --pkgname-spec "$PKGNAME_SPEC" \
  --output "$FEED_DIR/packages.adb" \
  "$FEED_DIR"/*.apk

# The workflow uploads the signed APK to a GitHub Release before deploying the
# feed. The package is removed from dist later because Cloudflare's static
# asset limit is smaller than the APK.
