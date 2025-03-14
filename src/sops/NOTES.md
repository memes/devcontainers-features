<!-- markdownlint-disable MD041 -->
## OS Support

This feature should support any base image that provides a POSIX shell to execute `install.sh`, and functional `curl`
binary.

It has been tested and verified using the following images on ***amd64*** and ***arm64*** platforms:

* `mcr.microsoft.com/devcontainers/base:alpine`
* `mcr.microsoft.com/devcontainers/base:debian`
* `mcr.microsoft.com/devcontainers/base:ubuntu`
* `registry.fedoraproject.org/fedora:latest`
* `registry.access.redhat.com/ubi9/ubi:latest` NOTE: `age` package is not in standard RHEL repos and will not be installed by this feature

## Installation methods

| |Distro package|GitHub Release|Default|
|-|----|--------------|-------|
|Alpine| | &check; | GitHub |
|Debian| | &check; | GitHub |
|Fedora| | &check; | GitHub |
|RedHat UBI9| | &check; | GitHub |
|Ubuntu| | &check; | GitHub |
|*others*| | &check; | GitHub |

All installs will be from a GitHub release tarball, with `age` and `gnupg2` packages installed from standard repos.
