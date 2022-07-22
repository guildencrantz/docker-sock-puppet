#!/usr/bin/env bash

# TODO:
# 1. Allow optionally forwarding SSH
# 2. Allow optionally forwarding GPG
# 3. Allow random socket forwarding

set -eo pipefail

IMAGE_NAME=ghcr.io/guildencrantz/sock-puppet:latest
CONTAINER_NAME=sock-puppet
VOLUME_NAME=sock-puppet

AUTHORIZED_KEYS=$(ssh-add -L | base64 | tr -d '\n')
KNOWN_HOSTS_FILE=$(mktemp -t sock-puppet.XXX)
GPG_EXTRA_SOCK=$(gpgconf --list-dir agent-extra-socket)

trap 'rm ${KNOWN_HOSTS_FILE}' EXIT

docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true

docker volume create --name "${VOLUME_NAME}"

MOUNT_FLAGS="=-v ${VOLUME_NAME}:/${VOLUME_NAME} -e SSH_AUTH_SOCK=/${VOLUME_NAME}/ssh-agent.sock -e GNUPGHOME=/${VOLUME_NAME}"

docker run                                \
  --name "${CONTAINER_NAME}"              \
  -d                                      \
  --restart=always                        \
  -e AUTHORIZED_KEYS="${AUTHORIZED_KEYS}" \
  -v ${VOLUME_NAME}:/sock-puppet          \
  -p 22                                   \
  -l "MOUNT_FLAGS=${MOUNT_FLAGS}"         \
  "${IMAGE_NAME}" >/dev/null

HOST_PORT=$(docker inspect -f '{{ (index (index .NetworkSettings.Ports "22/tcp") 0).HostPort }}' $CONTAINER_NAME)

if [ "${DOCKER_HOST}" ]; then
  HOST_IP=$(
    echo "$DOCKER_HOST"        |
      awk -F '//' '{print $2}' |
      awk -F ':' '{print $1}'
  )
else
  HOST_IP=127.0.0.1
fi

# FIXME Find a way to get rid of this additional 1s wait
sleep 1
while ! nc -z -w5 ${HOST_IP} ${HOST_PORT}; do sleep 0.1; done

ssh-keyscan -p "${HOST_PORT}" "${HOST_IP}" >"${KNOWN_HOSTS_FILE}" 2>/dev/null

ssh                                                \
  -o "UserKnownHostsFile=${KNOWN_HOSTS_FILE}"      \
  -p "${HOST_PORT}"                                \
  -S none                                          \
  "root@${HOST_IP}"                                \
  "echo 'no-autostart' > /${VOLUME_NAME}/gpg.conf"

# show the keys that are being forwarded
ssh                                           \
  -A                                          \
  -o "UserKnownHostsFile=${KNOWN_HOSTS_FILE}" \
  -p "${HOST_PORT}"                           \
  -S none                                     \
  "root@${HOST_IP}"                           \
  ssh-add -l

# TODO: BUILD REMOTE FORWARDS
# ContainerSocketPath -> LocalSocketPath
# For now just hard coding `-R` for the GPG sock
# Should also allow adding `-e` flags to the `MOUNT_FLAGS` on the container.

# keep the agent running, forwarding the SSH and GPG sockets
ssh "root@${HOST_IP}" -p "${HOST_PORT}"            \
  -fAT                                             \
  -S none                                          \
  -o "UserKnownHostsFile=${KNOWN_HOSTS_FILE}"      \
  -o "ExitOnForwardFailure=yes"                    \
  -R /${VOLUME_NAME}/S.gpg-agent:${GPG_EXTRA_SOCK} \
  /ssh-entrypoint.sh

# import public keys
gpg --list-secret-keys --with-colons |
  awk -F: '/^sec/ {print $5}'        |
  xargs -n 1 gpg --export -a         |
  ssh -o "UserKnownHostsFile=${KNOWN_HOSTS_FILE}" \
      -p "${HOST_PORT}"                           \
      -S none                                     \
      "root@${HOST_IP}"                           \
      gpg --homedir "/${VOLUME_NAME}" --import

echo <<\EOF
Agent forwarding successfully started.
Run `sock-puppet-mount` to get a command-line fragment that
can be added to `docker run` to mount the sockets.

For example:
docker run -it $(sock-puppet-mount) guildencrantz/sock-puppet ssh -T git@github.com
EOF
