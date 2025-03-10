<!-- markdownlint-disable MD041 -->
## OS Support

This feature should support any base image that provides a POSIX shell to execute `install.sh`, and functional `curl`
and `tar` binaries.

It has been tested and verified using the following images on ***amd64*** and ***arm64*** platforms:

* `mcr.microsoft.com/devcontainers/base:alpine`
* `mcr.microsoft.com/devcontainers/base:debian`
* `mcr.microsoft.com/devcontainers/base:ubuntu`
* `registry.fedoraproject.org/fedora:latest`
* `registry.access.redhat.com/ubi9/ubi:latest`

## Installation methods

| |Distro package|GitHub Release|Default|
|-|----|--------------|-------|
|Alpine| | &check; | GitHub |
|Debian| &check; | &check; | Package |
|Fedora| &check; | &check; | Package |
|RedHat UBI9| &check; | &check; | Package |
|Ubuntu| | &check; &check; | Package |
|*others*| | &check; | GitHub |

For the tested [OS images](#os-support) for which a supporting repo containing `goreleaser` package the **default**
installation method is to retrieve and install the latest *available* `goreleaser` package through `apt` or `dnf` tools.

When the OS is unrecognised, or if it is Alpine, the **default** install method is to download the latest tarball from
Google's servers.
