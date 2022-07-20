Forward unix sockets into a container

Based on (forked from)
[docker-ssh-agent-forward](https://github.com/uber-common/docker-ssh-agent-forward).


## Installation

Assuming you have a `/usr/local`

```bash
git clone git://github.com/guildencrantz/docker-sock-puppet
cd docker-sock-puppet
make
make install
```

On every boot, do:

```
sock-puppet-forward
```

and the you can run `sock-puppet-mount` to get a Docker CLI fragment that adds
the SSH agent socket and sets `SSH_AUTH_SOCK` within the container.

```
$ sock-puppet-mount -v ssh-agent:/ssh-agent -e SSH_AUTH_SOCK=/ssh-agent/ssh-agent.sock

$ docker run -it $(sock-puppet-mount) guildencrantz/sock-puppet ssh -T git@github.com

The authenticity of host 'github.com (192.30.252.128)' can't be established.
RSA key fingerprint is 16:27:ac:a5:76:28:2d:36:63:1b:56:4d:eb:df:a6:48.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'github.com,192.30.252.128' (RSA) to the list of known hosts.
PTY allocation request failed on channel 0
Hi avsm! You've successfully authenticated, but GitHub does not provide shell access.
```

To fetch the latest image, do:

```bash
sock-puppet-pull
```

## Troubleshooting

If sock-puppet-forward fails to run, run `ssh-add -l`. If there are no identities, then run `ssh-add`.

## Developing

To build an image yourself rather than fetching from Docker Hub, run
`./sock-puppet-build.sh` from your clone of this repo.

We didn't bother installing the build script with the Makefile since using the
hub image should be the common case.

## Contributors

* Matt Henkel
* Justin Cormack
* https://github.com/uber-common/docker-ssh-agent-forward/graphs/contributors

[License](LICENSE.md) is ISC.
