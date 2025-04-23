
# starship (starship)

Installs Starship from GitHub Release or Alpine repository and adds it to the global PATH.

## Example Usage

```json
"features": {
    "ghcr.io/memes/devcontainers-features/starship:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | The specific version to install; default value is 'latest' which will install the most recent available in distro repo or GitHub release. NOTE: If a version is provided and a matching distro package/GitHub Release can not be found the feature will fail. | string | latest |
| installFromGitHubRelease | If true download and install from GitHub release rather than Alpine package repository. | boolean | false |

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
|Debian| | &check; | GitHub |
|Fedora| | &check; | GitHub |
|RedHat UBI9| | &check; | GitHub |
|Ubuntu| | &check; | GitHub |
|*others*| | &check; | GitHub |

For the tested [OS images](#os-support) that have `starship` in their public package repo(s) the **default**
installation method is to retrieve and install the latest *available* `starship` package through `apk`. If a version is
requested, the installer will always retrieve from GitHub.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/memes/devcontainers-features/blob/main/src/starship/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
