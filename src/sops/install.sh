#!/usr/bin/env sh
set -e

case "${VERSION}" in
    latest)
        SOPS_VERSION=""
        ;;
    *)
        # Make sure version is a simple semver, without leading v or trailing debian revision
        SOPS_VERSION="${VERSION#v}"
        SOPS_VERSION="${SOPS_VERSION%%-*}"
        ;;
esac

INSTALLAGEANDGNUPG="${INSTALLAGEANDGNUPG:-"true"}"

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
    type awk >/dev/null 2>/dev/null || prereqs gawk
    type awk >/dev/null 2>/dev/null || error "awk is missing"
    type curl >/dev/null 2>/dev/null || error "curl is missing"
    if [ -z "${SOPS_VERSION}" ]; then
        SOPS_VERSION="$(curl -fsSL --retry 5 --retry-max-time 90 -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/getsops/sops/releases/latest 2>/dev/null | awk -F\" '/tag_name/ {print $4}')"
        SOPS_VERSION="${SOPS_VERSION#v}"
        [ -z "${SOPS_VERSION}" ] && error "Failed to get latest version tag from GitHub"
    fi
    case "$(uname -m)" in
        aarch64)
            sops_platform=arm64
            ;;
        x86_64)
            sops_platform=amd64
            ;;
        *)
            error "Unhandled machine arch $(uname -m)"
            ;;
    esac
    curl -fsSLo /usr/local/bin/sops --retry 5 --retry-max-time 90 "https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.${sops_platform}" || \
        error "Failed to download sops v${SOPS_VERSION} binary"
    chmod 0755 /usr/local/bin/sops
}

[ "$(id -u)" -eq 0 ] || error 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'

case "${INSTALLAGEANDGNUPG}" in
    true|TRUE)
        # shellcheck disable=SC1091
        . /etc/os-release
        # Age is not packaged for RHEL
        if [ "${ID}" != "rhel" ]; then
            type age >/dev/null 2>/dev/null || prereqs age
        fi
        type gpg >/dev/null 2>/dev/null || prereqs gnupg2
        ;;
    *)
        ;;
esac
install_from_github
