
# direnv (direnv)

Installs direnv from distro repository or GitHub release and adds it to the global PATH.

## Example Usage

```json
"features": {
    "ghcr.io/memes/devcontainers-features/direnv:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | The specific version to install; default value is 'latest' which will install the most recent available in distro repo or GitHub release. NOTE: If a version is provided and a matching distro package/GitHub Release can not be found the feature will fail. | string | latest |
| installFromGitHubRelease | When true, force pulling releases directly from published GitHub Release regardless of the default installation method. | boolean | false |

<!-- markdownlint-disable MD041 -->
## OS Support

This feature should support any base image that provides a POSIX shell to execute `install.sh`, and a functional `curl`
binary.

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
|RedHat UBI9| | &check; | GitHub |
|Ubuntu| &check; | &check; | Package |
|*others*| | &check; | GitHub |

For the tested [OS images](#os-support) that have `direnv` in their public package repo(s) the **default** installation
method is to retrieve and install the latest *available* `direnv` package through `apk`, `apt`, or `dnf` tools.

When the OS is unrecognised, or for tested [OS images](#os-support) that do not have `direnv` in a public repo, the
**default** install method is to download the latest release from `direnv`'s GitHub page.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
