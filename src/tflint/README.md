
# tflint (tflint)

Installs tflint from GitHub release or Alpine repository and adds it to the global PATH.

## Example Usage

```json
"features": {
    "ghcr.io/memes/devcontainers-features/tflint:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | The specific version to install; default value is 'latest' which will install the most recent available in GitHub release. NOTE: If a version is provided and a matching Alpine package/GitHub Release can not be found the feature will fail. | string | latest |
| installFromGitHubRelease | DEPRECATED: Installation of tflint is always from GitHub release, this flag is ignored. | boolean | false |

<!-- markdownlint-disable MD041 -->
## OS Support

This feature should support any base image that provides a POSIX shell to execute `install.sh`, and functional `curl` and `unzip` binaries.

It has been tested and verified using the following images on ***amd64*** and ***arm64*** platforms:

* `mcr.microsoft.com/devcontainers/base:alpine`
* `mcr.microsoft.com/devcontainers/base:debian`
* `mcr.microsoft.com/devcontainers/base:ubuntu`
* `registry.fedoraproject.org/fedora:latest`
* `registry.access.redhat.com/ubi9/ubi:latest`

## Installation methods

| |Distro package|GitHub Release|Default|
|-|----|--------------|-------|
|Alpine| | &check; | Package |
|Debian| | &check; | GitHub |
|Fedora| | &check; | GitHub |
|RedHat UBI9| | &check; | GitHub |
|Ubuntu| | &check; | GitHub |
|*others*| | &check; | GitHub |

At the time of publishing, no tested distro has `tflint` in their pubic repo; all installations will be a pull
from GitHub Release.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/memes/devcontainers-features/blob/main/src/tflint/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
