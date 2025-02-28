#!/usr/bin/env sh
set -e

case "${VERSION}" in
    latest)
        TERRAGRUNT_VERSION=""
        ;;
    *)
        # Make sure version is a simple semver, without leading v or trailing debian revision
        TERRAGRUNT_VERSION="${VERSION#v}"
        TERRAGRUNT_VERSION="${TERRAGRUNT_VERSION%%-*}"
        ;;
esac

error() {
    echo "ERROR: $*"
    exit 1
}

prereqs() {
    # shellcheck disable=SC1091
    . /etc/os-release
    case "${ID}" in
        *alpine*)
            apk --no-cache add "$@" || error "Failed to install apks for $*"
            ;;
        *rhel*|*fedora*)
            dnf install -y "$@" || error "Failed to install rpms for $*"
            rm -rf /var/cache/dnf/* /var/cache/yum/*
            ;;
        *debian*|*ubuntu*)
            DEBIAN_FRONTEND=noninteractive apt update
            DEBIAN_FRONTEND=noninteractive apt install -y "$@" || \
                error "Failed to install debs for $*"
            rm -rf /var/lib/apt/lists/*
            ;;
        *)
            ;;
    esac
}

install_from_github() {
    type curl >/dev/null 2>/dev/null || prereqs curl
    type curl >/dev/null 2>/dev/null || error "curl is missing"
    if [ -z "${TERRAGRUNT_VERSION}" ]; then
        TERRAGRUNT_VERSION="$(curl -fsSL -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest 2>/dev/null | awk -F\" '/tag_name/ {print $4}')"
        TERRAGRUNT_VERSION="${TERRAGRUNT_VERSION#v}"
        [ -z "${TERRAGRUNT_VERSION}" ] && error "Failed to get latest version tag from GitHub"
    fi
    case "$(uname -m)" in
        aarch64)
            terragrunt_platform=arm64
            ;;
        x86_64)
            terragrunt_platform=amd64
            ;;
        *)
            error "Unhandled machine arch $(uname -m)"
            ;;
    esac
    curl -sLo /usr/local/bin/terragrunt "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION#v}/terragrunt_linux_${terragrunt_platform}" || \
        error "Failed to download terragrunt v${TERRAGRUNT_VERSION} binary"
        chmod 0755 /usr/local/bin/terragrunt
}

[ "$(id -u)" -eq 0 ] || error 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'

install_from_github
