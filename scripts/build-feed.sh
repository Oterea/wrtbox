#!/bin/sh
set -eu

# Feed signing is performed with the OpenWrt 25.12 SDK apk-tools binary.
# The workflow will provide APK_TOOL and SIGN_KEY. The public key is copied
# into dist/ and is safe to publish.

: "${APK_TOOL:?APK_TOOL is required}"
: "${SIGN_KEY:?SIGN_KEY is required}"
: "${ARCH:=aarch64_generic}"
: "${FEED_DIR:=dist/openwrt-25.12/${ARCH}}"
: "${PKGNAME_SPEC:=https://gh-proxy.org/https://github.com/SagerNet/sing-box/releases/download/v\${version}/sing-box_\${version}_openwrt_\${arch}.apk}"

mkdir -p "$FEED_DIR"

"$APK_TOOL" mkndx --allow-untrusted \
  --sign-key "$SIGN_KEY" \
  --pkgname-spec "$PKGNAME_SPEC" \
  --output "$FEED_DIR/packages.adb" \
  "$FEED_DIR"/*.apk

# Cloudflare's static asset limit is smaller than the official sing-box APK.
# The index points at the proxied upstream Release asset, so do not publish
# the local APK through the Worker.
rm -f "$FEED_DIR"/*.apk
