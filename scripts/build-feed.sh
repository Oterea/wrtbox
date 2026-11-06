#!/bin/sh
set -eu

# Feed signing is performed with the OpenWrt 25.12 SDK apk-tools binary.
# The workflow will provide APK_TOOL and SIGN_KEY. The public key is copied
# into dist/ and is safe to publish.

: "${APK_TOOL:?APK_TOOL is required}"
: "${SIGN_KEY:?SIGN_KEY is required}"
: "${ARCH:=aarch64_generic}"
: "${FEED_DIR:=dist/openwrt-25.12/${ARCH}}"

mkdir -p "$FEED_DIR"

# The package must have the normal name-version.apk layout because apk
# resolves package files relative to the packages.adb index.
"$APK_TOOL" --allow-untrusted adbsign \
  --reset-signatures \
  --sign-key "$SIGN_KEY" \
  "$FEED_DIR"/*.apk

"$APK_TOOL" mkndx --allow-untrusted \
  --sign-key "$SIGN_KEY" \
  --pkgname-spec '${name}_${version}_openwrt_${arch}.apk' \
  --output "$FEED_DIR/packages.adb" \
  "$FEED_DIR"/*.apk
