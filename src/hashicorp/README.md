
# Hashicorp products (hashicorp)

Installs products from Hashicorp's published repository or release binary and adds it to the global PATH.

## Example Usage

```json
"features": {
    "ghcr.io/memes/devcontainers-features/hashicorp:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| packer | The specific version of Hashicorp Packer to install, or 'latest'. If left blank (default) then packer will not be added to devcontainer. | string | - |
| terraform | The specific version of Hashicorp Terraform to install, or 'latest'. If left blank (default) then terraform will not be added to devcontainer. | string | - |
| vault | The specific version of Hashicorp Vault to install, or 'latest'. If left blank (default) then vault will not be added to devcontainer. NOTE: Vault requires that the devcontainer be run with IPC_LOCK capability set, see README. | string | - |
| installBinaries | When true, force installing binary releases from releases.hashicorp.com regardless of the default installation method. | boolean | false |

<!-- markdownlint-disable MD041 -->
> NOTE: This feature **only** installs packages corresponding to a non-empty *option*; using this feature with a default
> or empty set of options will not install **any** HashiCorp package. One or more of `packer`, `terraform`, or `vault`
> options must be set to 'latest' or a specific version to install the package.

### Vault notes

**Vault** locks memory to prevent accidental paging to disk; the devcontainer must be launched with additional
capability IPC_LOCK enabled on Podman or Docker. This can be set in `devcontainers.json`, e.g.

```json
{
    "name": "my-project",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "capAdd": ["IPC_LOCK"],
    "features": {
        "ghcr.io/memes/devcontainers-features/hashicorp:1": {
            "vault": "latest"
        }
    }
}
```

Alternatively, the capabilities can be removed in an `onCreateCommand`, e.g.

```json
{
    "name": "my-project",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/memes/devcontainers-features/hashicorp:1": {
            "vault": "latest"
        }
    },
    "onCreateCommand": "sudo setcap cap_ipc_lock=-ep /usr/bin/vault"
}
```

## OS Support

This feature should support any base image that provides a POSIX shell to execute `install.sh`, and functional `curl`
and `unzip` binaries.

It has been tested and verified using the following images on ***amd64*** and ***arm64*** platforms:

* `mcr.microsoft.com/devcontainers/base:alpine` - NOTE: Feature will automatically install `libcap-setcap` to support
  setting capabilities on Vault binary if Vault is installed
* `mcr.microsoft.com/devcontainers/base:debian`
* `mcr.microsoft.com/devcontainers/base:ubuntu`
* `registry.fedoraproject.org/fedora:latest`
* `registry.access.redhat.com/ubi9/ubi:latest`

## Installation methods

| |Distro package|Release Binary|Default|
|-|----|--------------|-------|
|Alpine| | &check; | Binary |
|Debian| &check; | &check; | Package |
|Fedora| | &check; | Package |
|RedHat UBI9| &check; | &check; | Package |
|Ubuntu| &check; | &check; | Package |
|*others*| | &check; | Binary |

For the tested [OS images](#os-support) that have `goreleaser` in their public package repo(s) the **default**
installation method is to retrieve and install the latest *available* `goreleaser` package through `apt`, or `dnf`
tools. If a version is requested, the installer will always retrieve from GitHub.

When the OS is unrecognised, or if it is Alpine or Fedora, the **default** install method is to download the latest
binary from HashiCorp's releases site..


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/memes/devcontainers-features/blob/main/src/hashicorp/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
