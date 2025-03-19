<!-- markdownlint-disable MD041 -->
## OS Support

This feature should support any base image that provides a POSIX shell to execute `install.sh`, and functional `curl`
and `zcat` binaries.

It has been tested and verified using the following images on ***amd64*** and ***arm64*** platforms:

* `mcr.microsoft.com/devcontainers/base:alpine`
* `mcr.microsoft.com/devcontainers/base:debian`
* `mcr.microsoft.com/devcontainers/base:ubuntu`
* `registry.fedoraproject.org/fedora:latest`
* `registry.access.redhat.com/ubi9/ubi:latest`

## Installation methods

| |Distro package|GitLab Release|Default|
|-|----|--------------|-------|
|Alpine| | &check; | GitLab |
|Debian| | &check; | GitLab |
|Fedora| | &check; | GitLab |
|RedHat UBI9| | &check; | GitLab |
|Ubuntu| | &check; | GitLab |
|*others*| | &check; | GitLab |
