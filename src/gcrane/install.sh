#!/usr/bin/env sh
set -e

case "${VERSION}" in
    latest)
        GCRANE_VERSION=""
        ;;
    *)
        # Make sure version is a simple semver, without leading v or trailing debian revision
        GCRANE_VERSION="${VERSION#v}"
        GCRANE_VERSION="${GCRANE_VERSION%%-*}"
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
    type tar >/dev/null 2>/dev/null || prereqs tar
    type awk >/dev/null 2>/dev/null || prereqs gawk
    type awk >/dev/null 2>/dev/null || error "awk is missing"
    type curl >/dev/null 2>/dev/null || error "curl is missing"
    type tar >/dev/null 2>/dev/null || error "tar is missing"
    if [ -z "${GCRANE_VERSION}" ]; then
        GCRANE_VERSION="$(curl -fsSL --retry 5 --retry-max-time 90 ${GITHUB_TOKEN:+"-H 'Authorization: Bearer ${GITHUB_TOKEN}'"} -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/google/go-containerregistry/releases/latest 2>/dev/null | awk -F\" '/tag_name/ {print $4}')"
        GCRANE_VERSION="${GCRANE_VERSION#v}"
        [ -z "${GCRANE_VERSION}" ] && error "Failed to get latest version tag from GitHub"
    fi
    case "$(uname -m)" in
        aarch64)
            gcrane_platform=arm64
            ;;
        x86_64)
            gcrane_platform=x86_64
            ;;
        *)
            error "Unhandled machine arch $(uname -m)"
            ;;
    esac
    curl -fsSL --retry 5 --retry-max-time 90 \
        "https://github.com/google/go-containerregistry/releases/download/v${GCRANE_VERSION}/go-containerregistry_Linux_${gcrane_platform}.tar.gz" | \
        tar xzf - -C /usr/local/bin crane gcrane krane || \
        error "Failed to download go-containerregistry v${GCRANE_VERSION} tarball"
    chmod 0755 /usr/local/bin/*rane
}

[ "$(id -u)" -eq 0 ] || error 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'

install_from_github
