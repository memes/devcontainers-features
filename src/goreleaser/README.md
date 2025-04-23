
# goreleaser (goreleaser)

Installs goreleaser and supporting files from GitHub release tarball and adds it to the global PATH.

## Example Usage

```json
"features": {
    "ghcr.io/memes/devcontainers-features/goreleaser:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | The specific version to install; default value is 'latest' which will install the most recent available release of goreleaser. NOTE: If a version is provided and a matching release can not be found the feature will fail. | string | latest |
| installFromGitHubRelease | When true, force pulling releases directly from published GitHub tarball regardless of the default installation method. | boolean | false |
| pro | If true, install goreleaser pro binaries. NOTE: A license key will be required to use the pro version. | boolean | false |

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
|Ubuntu| &check; | &check; | Package |
|*others*| | &check; | GitHub |

For the tested [OS images](#os-support) that have `goreleaser` in their public package repo(s) the **default**
installation method is to retrieve and install the latest *available* `goreleaser` package through `apt`, or `dnf`
tools. If a version is requested, the installer will always retrieve from GitHub.

When the OS is unrecognised, or if it is Alpine, the **default** install method is to download the latest tarball from
GitHub release.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/memes/devcontainers-features/blob/main/src/goreleaser/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
