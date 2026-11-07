#!/bin/sh
set -eu

# This script is run on GitHub Actions. It reads the latest stable or
# prerelease sing-box release from the GitHub API, then downloads the official
# OpenWrt APK asset for each requested architecture. It never runs on the router.

: "${GITHUB_OUTPUT:=/dev/null}"
: "${ARCH:=aarch64_generic}"
: "${OPENWRT_SERIES:=25.12}"
: "${CHANNEL:=stable}"
: "${OUT_DIR:=dist/openwrt-${OPENWRT_SERIES}/${CHANNEL}/${ARCH}}"
: "${GH_TOKEN:=${GITHUB_TOKEN:-}}"

case "$CHANNEL" in
  stable)
    releases_url="https://api.github.com/repos/SagerNet/sing-box/releases/latest"
    ;;
  beta)
    releases_url="https://api.github.com/repos/SagerNet/sing-box/releases?per_page=100"
    ;;
  *)
    echo "Unsupported channel: $CHANNEL" >&2
    exit 1
    ;;
esac

mkdir -p "$OUT_DIR"

if [ -n "$GH_TOKEN" ]; then
  release_json="$(curl --fail --silent --show-error \
    --retry 5 --retry-all-errors --retry-delay 5 \
    --connect-timeout 20 --max-time 60 \
    -H 'Accept: application/vnd.github+json' \
    -H "Authorization: Bearer $GH_TOKEN" \
    "$releases_url")"
else
  release_json="$(curl --fail --silent --show-error \
    --retry 5 --retry-all-errors --retry-delay 5 \
    --connect-timeout 20 --max-time 60 \
    -H 'Accept: application/vnd.github+json' \
    "$releases_url")"
fi

if [ "$CHANNEL" = beta ]; then
  release_json="$(printf '%s' "$release_json" | jq -c 'map(select(.prerelease == true)) | .[0]')"
fi

version="$(printf '%s' "$release_json" | jq -r '.tag_name')"
[ -n "$version" ] && [ "$version" != "null" ]

asset_url="$(printf '%s' "$release_json" | jq -r --arg arch "$ARCH" '
  .assets[]
  | select(.name | test("^sing-box_[^_]+_openwrt_" + $arch + "\\.apk$"))
  | .browser_download_url
  ' | head -n 1)"

[ -n "$asset_url" ]
asset_name="${asset_url##*/}"

asset_tmp="$OUT_DIR/$asset_name.part"
downloaded=0
for download_url in \
  "$asset_url" \
  "https://gh-proxy.org/$asset_url"; do
  echo "Trying sing-box APK: $download_url"
  if curl --fail --location --silent --show-error \
    --retry 5 --retry-all-errors --retry-delay 5 \
    --connect-timeout 20 --max-time 300 \
    "$download_url" -o "$asset_tmp"; then
    downloaded=1
    break
  fi
  rm -f "$asset_tmp"
done

test "$downloaded" = 1
mv "$asset_tmp" "$OUT_DIR/$asset_name"

printf 'version=%s\n' "$version" >> "$GITHUB_OUTPUT"
printf 'asset=%s\n' "$asset_name" >> "$GITHUB_OUTPUT"
