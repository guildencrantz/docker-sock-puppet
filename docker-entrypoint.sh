#!/bin/sh
set -eo pipefail

# Set a root password
echo "root:$(head -c 500 /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9~!@#$%^&*_-' | head -c 32)" |
  chpasswd

echo "$AUTHORIZED_KEYS" | base64 -d >/root/.ssh/authorized_keys

chown root:root /root/.ssh/authorized_keys

ssh-keygen -A

exec "$@"
