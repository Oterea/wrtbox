#!/bin/sh
set -eu

# Prepare a fresh Ubuntu server for wrtbox APK uploads and public downloads.
# Run this from the machine whose SSH key can already log in as SERVER_USER.
# The optional public-key file is the dedicated GitHub Actions upload key.

SERVER_HOST=${1:?usage: $0 SERVER_HOST [SERVER_USER] [ACTIONS_PUBLIC_KEY_FILE]}
SERVER_USER=${2:-ubuntu}
ACTIONS_PUBLIC_KEY_FILE=${3:-}

case "$SERVER_HOST" in
  *[!A-Za-z0-9.-]*) echo "invalid server host: $SERVER_HOST" >&2; exit 1 ;;
esac
case "$SERVER_USER" in
  *[!A-Za-z0-9._-]*) echo "invalid server user: $SERVER_USER" >&2; exit 1 ;;
esac

if [ -n "$ACTIONS_PUBLIC_KEY_FILE" ]; then
  test -r "$ACTIONS_PUBLIC_KEY_FILE"
  actions_public_key=$(cat "$ACTIONS_PUBLIC_KEY_FILE")
  case "$actions_public_key" in
    ssh-ed25519\ *|ssh-rsa\ *|ecdsa-sha2-*\ *) : ;;
    *) echo "unsupported or invalid public key file" >&2; exit 1 ;;
  esac
else
  actions_public_key=
fi

printf '%s\n' "Preparing $SERVER_USER@$SERVER_HOST"
encoded_key=$(printf '%s' "$actions_public_key" | base64 | tr -d '\n')
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new "$SERVER_USER@$SERVER_HOST" \
  "ACTIONS_PUBLIC_KEY=$encoded_key" 'sh -s' <<'REMOTE_SCRIPT'
set -eu

if [ "$(id -u)" -eq 0 ]; then
  SUDO=
else
  SUDO=sudo
fi

$SUDO apt-get update
$SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y nginx rsync
$SUDO install -d -o "$(id -un)" -g www-data -m 2775 /srv/wrtbox/stable /srv/wrtbox/beta

if [ -n "${ACTIONS_PUBLIC_KEY:-}" ]; then
  key_dir="$HOME/.ssh"
  mkdir -p "$key_dir"
  chmod 700 "$key_dir"
  key_file="$key_dir/authorized_keys"
  touch "$key_file"
  chmod 600 "$key_file"
  decoded_key=$(printf '%s' "$ACTIONS_PUBLIC_KEY" | base64 --decode)
  grep -qxF "$decoded_key" "$key_file" 2>/dev/null || printf '%s\n' "$decoded_key" >> "$key_file"
fi

$SUDO rm -f /etc/nginx/sites-enabled/default
$SUDO tee /etc/nginx/sites-available/wrtbox >/dev/null <<'NGINX_CONFIG'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    root /srv/wrtbox;
    autoindex off;

    location / {
        add_header Cache-Control "public, max-age=300" always;
    }
}
NGINX_CONFIG
$SUDO ln -sfn /etc/nginx/sites-available/wrtbox /etc/nginx/sites-enabled/wrtbox
$SUDO nginx -t
$SUDO systemctl enable --now nginx
$SUDO systemctl reload nginx

if command -v ufw >/dev/null 2>&1 && $SUDO ufw status 2>/dev/null | grep -q active; then
  $SUDO ufw allow 80/tcp >/dev/null
fi

printf '%s\n' 'wrtbox server is ready'
REMOTE_SCRIPT
