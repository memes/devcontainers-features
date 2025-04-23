
# vesctl (vesctl)

Installs vesctl from GitLab release and adds it to the global PATH.

## Example Usage

```json
"features": {
    "ghcr.io/memes/devcontainers-features/vesctl:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | The specific version to install; default value is 'latest' which will install the most recent available GitLab release of vesctl. NOTE: If a version is provided and a matching GitHub Release can not be found the feature will fail. | string | latest |

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

At the time of publishing, no tested distro has `vesctl` in their pubic repo; all installations will be a pull
from GitLab.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/memes/devcontainers-features/blob/main/src/vesctl/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
