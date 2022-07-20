#!/usr/bin/env bash

docker inspect -f '{{ .Config.Labels.MOUNT_FLAGS }}' sock-puppet
