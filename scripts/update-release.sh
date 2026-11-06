#!/bin/sh
set -eu

# This script is run on GitHub Actions. It reads the latest stable sing-box
# release from the GitHub API, then downloads the official OpenWrt APK asset
# for each requested architecture. It never runs on the router.

: "${GITHUB_OUTPUT:=/dev/null}"
: "${ARCH:=aarch64_generic}"
: "${OUT_DIR:=dist/openwrt-25.12/${ARCH}}"

mkdir -p "$OUT_DIR"

release_json="$(curl --fail --silent --show-error \
  -H 'Accept: application/vnd.github+json' \
  https://api.github.com/repos/SagerNet/sing-box/releases/latest)"

version="$(printf '%s' "$release_json" | jq -r '.tag_name')"
[ -n "$version" ] && [ "$version" != "null" ]

asset_url="$(printf '%s' "$release_json" | jq -r --arg arch "$ARCH" '
  .assets[]
  | select(.name | test("^sing-box_[^_]+_openwrt_" + $arch + "\\.apk$"))
  | .browser_download_url
  ' | head -n 1)"

[ -n "$asset_url" ]
asset_name="${asset_url##*/}"

curl --fail --location --silent --show-error \
  "$asset_url" \
  -o "$OUT_DIR/$asset_name"

printf 'version=%s\n' "$version" >> "$GITHUB_OUTPUT"
printf 'asset=%s\n' "$asset_name" >> "$GITHUB_OUTPUT"
