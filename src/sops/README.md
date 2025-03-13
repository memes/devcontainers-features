
# sops (sops)

Installs sops binary from GitHub release tarball and adds it to the global PATH. Supporting packages age and GnuPG will be added to the container if not already present.

## Example Usage

```json
"features": {
    "ghcr.io/memes/devcontainers-features/sops:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | The specific version to install; default value is 'latest' which will install the most recent available GitHub release of sops. NOTE: If a version is provided and a matching GitHub Release can not be found the feature will fail. | string | latest |
| installAgeAndGnuPG | When true (default), ensure that age and GnuPG packages are installed in container. | boolean | true |

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


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/memes/devcontainers-features/blob/main/src/sops/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
