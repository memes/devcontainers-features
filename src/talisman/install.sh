#!/usr/bin/env sh
set -e

case "${VERSION}" in
    latest)
        TALISMAN_VERSION=""
        ;;
    *)
        # Make sure version is a simple semver, without leading v or trailing debian revision
        TALISMAN_VERSION="${VERSION#v}"
        TALISMAN_VERSION="${TALISMAN_VERSION%%-*}"
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
            dnf install -y --setopt=install_weak_deps=False "$@" || error "Failed to install rpms for $*"
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
    if [ -z "${TALISMAN_VERSION}" ]; then
        TALISMAN_VERSION="$(curl -fsSL --retry 5 --retry-max-time 90 ${GITHUB_TOKEN:+"-H 'Authorization: Bearer ${GITHUB_TOKEN}'"} -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/thoughtworks/talisman/releases/latest 2>/dev/null | awk -F\" '/tag_name/ {print $4}')"
        TALISMAN_VERSION="${TALISMAN_VERSION#v}"
        [ -z "${TALISMAN_VERSION}" ] && error "Failed to get latest version tag from GitHub"
    fi
    case "$(uname -m)" in
        aarch64)
            talisman_platform=arm64
            ;;
        x86_64)
            talisman_platform=amd64
            ;;
        *)
            error "Unhandled machine arch $(uname -m)"
            ;;
    esac
    curl -fsSLo /usr/local/bin/talisman --retry 5 --retry-max-time 90 "https://github.com/thoughtworks/talisman/releases/download/v${TALISMAN_VERSION}/talisman_linux_${talisman_platform}" || \
        error "Failed to download talisman v${TALISMAN_VERSION} binary"
    chmod 0755 /usr/local/bin/talisman
}

[ "$(id -u)" -eq 0 ] || error 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'

install_from_github
