
# Google Cloud SDK CLI (google-cloud-cli)

Installs Google Cloud SDK CLI from distro repository or published tarball and adds it to the global PATH.

## Example Usage

```json
"features": {
    "ghcr.io/memes/devcontainers-features/google-cloud-cli:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | The specific version of Google Cloud SDK to install; default value is 'latest' which will install the most recent available in distro repo or Google published tarball. NOTE: If a version is provided and a matching package/tarball can not be found the feature will fail. | string | latest |
| installFromTarball | When true, force pulling releases directly from published tarball regardless of the default installation method. | boolean | false |
| components | Install additional components provided by Google Cloud SDK as a space separated list of components identifiers. The identifiers of the components must match those shown by [gcloud components list](https://cloud.google.com/sdk/docs/components#listing_components) regardless of installation method - the script will translate component ids to package names as needed. | string | - |

<!-- markdownlint-disable MD041 -->
## Sharing gcloud config and authentication tokens from host

This feature does not automatically mount `gcloud` tokens from the host, or perform `gcloud init` to avoid accidentally
leaking creds into a demo gitpod environment, for example. To avoid running `gcloud auth login` in the devcontainer and
reuse the SSH keys and GCP authentications from your host, define bind mounts for the `gcloud` and `ssh` config
directories.

```json
{
    "name": "my-devcontainer",
    "image": "mcr.microsoft.com/devcontainers/go:1.24-bookworm",
    "containerUser": "vscode",
    "features": {
        "ghcr.io/memes/devcontainer-features/google-cloud-cli": {
            "version": "511.0.0",
            "components": "pubsub-emulator istioctl kubectl"
        }
    },.
    "mounts": [
        "source=${localEnv:HOME}/.config/gcloud,target=/home/vscode/.config/gcloud,type=bind",
        "source=${localEnv:HOME}${localEnv:USERPROFILE}/.ssh,target=/home/vscode/.ssh,type=bind,readonly"
    ]
}
```

## OS Support

This feature should support any base image that provides a POSIX shell to execute `install.sh`, and functional `curl` and `tar` binaries.

It has been tested and verified using the following images on ***amd64*** and ***arm64*** platforms:

* `mcr.microsoft.com/devcontainers/base:alpine`
* `mcr.microsoft.com/devcontainers/base:debian`
* `mcr.microsoft.com/devcontainers/base:ubuntu`
* `registry.fedoraproject.org/fedora:latest`
* `registry.access.redhat.com/ubi9/ubi:latest`

## Installation methods

| |Distro package|Tarball|Default|
|-|----|--------------|-------|
|Alpine| | &check; | Tarball |
|Debian| &check; | &check; | Package |
|Fedora| &check; | &check; | Package |
|RedHat UBI9| &check; | &check; | Package |
|Ubuntu| &check; | &check; | Package |
|*others*| | &check; | Tarball |

For the tested [OS images](#os-support) for which Google has created a supporting repo containing `gcloud` component
packages the **default** installation method is to retrieve and install the latest *available* `gcloud` and *components*
packages through `apt` or `dnf` tools.

When the OS is unrecognised, or if it is Alpine, the **default** install method is to download the latest tarball from
Google's servers.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
