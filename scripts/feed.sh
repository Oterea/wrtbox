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

REPOSITORY_URL="https://wrtbox.czuouo.workers.dev"
FEED_URL="$REPOSITORY_URL/openwrt-$SERIES/$ARCH/packages.adb"
KEY_FILE="/etc/apk/keys/wrtbox.pem"
REPOSITORY_FILE="/etc/apk/repositories.d/customfeeds.list"

mkdir -p "$(dirname "$KEY_FILE")" "$(dirname "$REPOSITORY_FILE")"

echo "Installing wrtbox signing key"
if command -v wget >/dev/null 2>&1; then
    wget -q -O "$KEY_FILE" "$REPOSITORY_URL/public-key.pem"
elif command -v curl >/dev/null 2>&1; then
    curl -fsSL -o "$KEY_FILE" "$REPOSITORY_URL/public-key.pem"
else
    echo "Neither wget nor curl is available." >&2
    exit 1
fi

# Keep other custom feeds (including momo) and replace only the wrtbox entry.
touch "$REPOSITORY_FILE"
sed -i '/wrtbox\.czuouo\.workers\.dev/d' "$REPOSITORY_FILE"
echo "$FEED_URL" >> "$REPOSITORY_FILE"

echo "Updating APK repositories"
apk update

echo "wrtbox feed configured for OpenWrt $SERIES ($ARCH)"
echo "Install sing-box with: apk add --force-overwrite sing-box"
