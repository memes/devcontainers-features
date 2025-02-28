# MEmes' devcontainer features

![Maintenance](https://img.shields.io/maintenance/yes/2025)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)

This repository contains a _collection_ of small devcontainer Features that can add-in common utilities used when
authoring shared demos and repositories. For example, I'm using these to support a transition from a mix of `asdf` and
`direnv` per-project configurations on personal and work devices to a development strategy with devpods and VSCode.

## Usage

To reference a Feature from this repository, add the desired Features to a devcontainer.json. Each Feature has a
`README.md` that shows how to reference the Feature and which options are available for that Feature.

The example below installs the Features [`google-cloud-cli`](https://cloud.google.com/cli) and
[`talisman`](https://thoughtworks.github.io/talisman/) at fixed versions (replacing project `.tool-versions`), along
with whatever is the latest release of [starship](https://starship.rs)

```json
{
    "name": "my-project",
    "image": "mcr.microsoft.com/devcontainers/go:1.24-bookworm",
    "features": {
        "ghcr.io/memes/devcontainers-features/google-cloud-cli:1": {
            "version": "511.0.0",
            "components": "pubsub-emulator istioctl kubectl"
        },
        "ghcr.io/memes/devcontainer-features/starship:1": {},
        "ghcr.io/memes/devcontainer-features/talisman:1": {
            "version": "1.32.0"
        }
    },
    "mounts": [
        "source=${localEnv:HOME}/.config/gcloud,target=/home/vscode/.config/gcloud,type=bind",
        "source=${localEnv:HOME}${localEnv:USERPROFILE}/.ssh,target=/home/vscode/.ssh,type=bind,readonly"
    ]
}
```
