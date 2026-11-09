#!/bin/sh
set -eu

# Configure the wrtbox APK feed on OpenWrt/ImmortalWrt.
# This script only switches the feed and refreshes the package index.

if [ ! -x /usr/bin/apk ]; then
    echo "This feed script requires an OpenWrt system using apk." >&2
    exit 1
fi

. /etc/openwrt_release

case "${0##*/}" in
    stable|beta)
        CHANNEL="${0##*/}"
        MODE="${1:-auto}"
        ;;
    *)
        CHANNEL="${1:-stable}"
        MODE="${2:-auto}"
        ;;
esac

case "$CHANNEL" in
    stable|beta) ;;
    *)
        echo "Usage: feed.sh [stable|beta] [auto|server|ghproxy|direct]" >&2
        exit 1
        ;;
esac

case "$MODE" in
    auto|server|ghproxy|direct) ;;
    *)
        echo "Usage: feed.sh [stable|beta] [auto|server|ghproxy|direct]" >&2
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
KEY_FILE="/etc/apk/keys/wrtbox.pem"
REPOSITORY_FILE="/etc/apk/repositories.d/customfeeds.list"

mkdir -p "$(dirname "$KEY_FILE")" "$(dirname "$REPOSITORY_FILE")"

echo "Installing wrtbox signing key"
KEY_TMP="${KEY_FILE}.tmp.$$"
trap 'rm -f "$KEY_TMP"' EXIT
if ! command -v wget >/dev/null 2>&1; then
    echo "BusyBox wget is required." >&2
    exit 1
fi

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
mv "$KEY_TMP" "$KEY_FILE"

# In auto mode, prefer gh-proxy.org. If it fails, use direct GitHub while
# sing-box is already running; otherwise use the domestic server for first install.
if [ "$MODE" = auto ]; then
    if wget -q -T 12 --spider \
         "https://gh-proxy.org/https://github.com/Oterea/wrtbox/releases/latest"; then
        MODE=ghproxy
    elif pidof sing-box >/dev/null 2>&1 && \
         wget -q -T 12 --spider \
           "https://github.com/Oterea/wrtbox/releases/latest"; then
        MODE=direct
    else
        MODE=server
    fi
fi

FEED_URL="$REPOSITORY_URL/openwrt-$SERIES/$CHANNEL/$MODE/$ARCH/packages.adb"

# Keep every unrelated custom feed untouched. Remove only wrtbox entries,
# including entries that the user commented out in LuCI, then add one active
# entry for the selected mode.
touch "$REPOSITORY_FILE"
sed -i \
    -e '\|^[[:space:]]*#\?[[:space:]]*https://wrtbox\.pages\.dev/|d' \
    -e '\|^[[:space:]]*#\?[[:space:]]*https://wrtbox\.czuouo\.workers\.dev/|d' \
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

echo "wrtbox $CHANNEL/$MODE feed configured for OpenWrt $SERIES ($ARCH)"
echo "Install or upgrade sing-box with: apk add sing-box"
