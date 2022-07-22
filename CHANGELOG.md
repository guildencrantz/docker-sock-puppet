# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- This `CHANGELOG.md`

### Removed
- `.vscode` 

### Security
- Set `root` password in container.

## [0.1.1] - 2022-07-22

### Added
- Set container to `restart=always`

### Fixed
- Consistently use `ghcr.io/guildencrantz/sock-puppet` for `IMAGE_NAME`

### Changed
- Move `MOUNT_FLAGS` into a variable.

## [0.1.0] - 2022-07-20

Initial `sock-puppet` release, based on
[uber-common/docker-ssh-agent-forward](https://github.com/uber-common/docker-ssh-agent-forward/commit/7e26e9bf574b4cda7bd12c6e8b7529a852cb2322).

### Added
- GitHub Workflow Action to publish container to ghcr.io
- When starting container set `MOUNT_FLAGS` label.
- Remote mount the `GPG_EXTRA_SOCK` (`gpgconf --list-dir agent-extra-socket`)
  into the container.
- Ensure `gpg.conf` has `no-autostart` configured.
- Import the public keys into the container.

### Changed
- Rename `ssh-agent`/`pinata-ssh` to `sock-puppet`
- Quick pass at documentation expanding updating names and paths/URIs.
- Update image from `alpine:3.7` to `alpine:3.16`
- `mount` script now uses `MOUNT_FLAGS` label on the running container.
- `HOST_PORT` is now assigned by docker and pulled from the running container

[Unreleased]: https://github.com/guildencrantz/docker-sock-puppet/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/guildencrantz/docker-sock-puppet/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/guildencrantz/docker-sock-puppet/compare/7e26e9bf574b4cda7bd12c6e8b7529a852cb2322...v0.1.0
