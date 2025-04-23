<!-- markdownlint-disable MD041 -->
## OS Support

This feature should support any base image that provides a POSIX shell to execute `install.sh`, and functional `curl` and `tar` binaries.

It has been tested and verified using the following images on ***amd64*** and ***arm64*** platforms:

* `mcr.microsoft.com/devcontainers/base:alpine`
* `mcr.microsoft.com/devcontainers/base:debian`
* `mcr.microsoft.com/devcontainers/base:ubuntu`
* `registry.fedoraproject.org/fedora:latest`
* `registry.access.redhat.com/ubi9/ubi:latest`

## Installation methods

| |Distro package|GitHub Release|Default|
|-|----|--------------|-------|
|Alpine| &check; | &check; | Package |
|Debian| &check; | &check; | Package |
|Fedora| &check; | &check; | Package |
|RedHat UBI9| &check; | &check; | Package |
|Ubuntu| &check; | &check; | Package |
|*others*| | &check; | GitHub |

For the tested [OS images](#os-support) that have `tofu` or `opentofu` in their public package repo(s) the **default**
installation method is to retrieve and install the latest *available* `tofu` or `opentofu` package through `apk`, `apt`,
or `dnf` tools. If a version is requested, the installer will always retrieve from GitHub.

When the OS is unrecognised, or for tested [OS images](#os-support) that do not have `tofu` or `opentofu` in a public
repo, the **default** install method is to download the latest release from OpenTofu's GitHub page.
