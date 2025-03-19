#!/usr/bin/env sh
set -e

case "${VERSION}" in
    latest)
        VESCTL_VERSION=""
        ;;
    *)
        # Make sure version is a simple semver, without leading v or trailing debian revision
        VESCTL_VERSION="${VERSION#v}"
        VESCTL_VERSION="${VESCTL_VERSION%%-*}"
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

install_from_gitlab() {
    type curl >/dev/null 2>/dev/null || prereqs curl
    type curl >/dev/null 2>/dev/null || error "curl is missing"
    type zcat >/dev/null 2>/dev/null || prereqs gzip
    type zcat >/dev/null 2>/dev/null || error "zcat is missing"
    if [ -z "${VESCTL_VERSION}" ]; then
        VESCTL_VERSION="$(curl -fsSL --retry 5 --retry-max-time 90 https://downloads.volterra.io/releases/vesctl/latest.txt 2>/dev/null)"
        VESCTL_VERSION="${VESCTL_VERSION#v}"
        [ -z "${VESCTL_VERSION}" ] && error "Failed to get latest version tag from GitHub"
    fi
    case "$(uname -m)" in
        aarch64)
            vesctl_platform=arm64
            ;;
        x86_64)
            vesctl_platform=amd64
            ;;
        *)
            error "Unhandled machine arch $(uname -m)"
            ;;
    esac
    curl -fsSL --retry 5 --retry-max-time 90 "https://vesio.azureedge.net/releases/vesctl/${VESCTL_VERSION}/vesctl.linux-${vesctl_platform}.gz" | \
        zcat > /usr/local/bin/vesctl || \
            error "Failed to download vesctl v${VESCTL_VERSION} gzipped-binary"
    chmod 0755 /usr/local/bin/vesctl
}

[ "$(id -u)" -eq 0 ] || error 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'

install_from_gitlab
