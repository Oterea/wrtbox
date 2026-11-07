#!/bin/sh
set -eu

# Install the wrtbox APK feed on OpenWrt/ImmortalWrt.
# This script only configures the feed and refreshes the package index;
# it does not install sing-box itself.

if [ ! -x /usr/bin/apk ]; then
    echo "This feed script requires an OpenWrt system using apk." >&2
    exit 1
fi

. /etc/openwrt_release

CHANNEL="${1:-stable}"
case "$CHANNEL" in
    stable|beta) ;;
    *)
        echo "Usage: feed.sh [stable|beta]" >&2
        exit 1
        ;;
esac

case "${DISTRIB_RELEASE:-}" in
    *25.12*) SERIES="25.12" ;;
    *)
        echo "Unsupported OpenWrt release: ${DISTRIB_RELEASE:-unknown}" >&2
        echo "This feed currently publishes OpenWrt 25.12 packages." >&2
        exit 1
        ;;
esac

ARCH="${DISTRIB_ARCH:-$(cat /etc/apk/arch 2>/dev/null || true)}"
if [ -z "$ARCH" ]; then
    echo "Unable to determine OpenWrt architecture." >&2
    exit 1
fi

REPOSITORY_URL="https://wrtbox.pages.dev"
FEED_URL="$REPOSITORY_URL/openwrt-$SERIES/$CHANNEL/$ARCH/packages.adb"
KEY_FILE="/etc/apk/keys/wrtbox.pem"
REPOSITORY_FILE="/etc/apk/repositories.d/customfeeds.list"

mkdir -p "$(dirname "$KEY_FILE")" "$(dirname "$REPOSITORY_FILE")"

echo "Installing wrtbox signing key"
KEY_TMP="${KEY_FILE}.tmp.$$"
trap 'rm -f "$KEY_TMP"' EXIT
if command -v wget >/dev/null 2>&1; then
    downloaded=0
    for attempt in 1 2 3 4 5; do
        if wget -q -T 20 -O "$KEY_TMP" \
            "$REPOSITORY_URL/public-key.pem"; then
            downloaded=1
            break
        fi
        rm -f "$KEY_TMP"
        sleep 2
    done
    test "$downloaded" = 1
elif command -v curl >/dev/null 2>&1; then
    curl -fsSL --retry 5 --retry-all-errors --retry-delay 2 \
        -o "$KEY_TMP" "$REPOSITORY_URL/public-key.pem"
else
    echo "Neither wget nor curl is available." >&2
    exit 1
fi
mv "$KEY_TMP" "$KEY_FILE"

# Keep other custom feeds (including momo) and replace only the wrtbox entry.
touch "$REPOSITORY_FILE"
sed -i \
    -e '\|^https://wrtbox\.pages\.dev/|d' \
    -e '\|^https://wrtbox\.czuouo\.workers\.dev/|d' \
    "$REPOSITORY_FILE"
echo "$FEED_URL" >> "$REPOSITORY_FILE"

echo "Updating APK repositories"
updated=0
for attempt in 1 2 3 4 5; do
    if apk update; then
        updated=1
        break
    fi
    sleep 2
done
test "$updated" = 1

echo "wrtbox $CHANNEL feed configured for OpenWrt $SERIES ($ARCH)"
echo "Install or upgrade sing-box with: apk add sing-box"
