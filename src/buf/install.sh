#!/usr/bin/env sh
set -e

case "${VERSION}" in
    latest)
        BUF_VERSION=""
        ;;
    *)
        # Make sure version is a simple semver, without leading v or trailing debian revision
        BUF_VERSION="${VERSION#v}"
        BUF_VERSION="${BUF_VERSION%%-*}"
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
    type curl >/dev/null 2>/dev/null || error "curl is missing"
    type tar >/dev/null 2>/dev/null || error "tar is missing"
    if [ -z "${BUF_VERSION}" ]; then
        BUF_VERSION="$(curl -fsSL --retry 5 --retry-max-time 90 -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/bufbuild/buf/releases/latest 2>/dev/null | awk -F\" '/tag_name/ {print $4}')"
        BUF_VERSION="${BUF_VERSION#v}"
        [ -z "${BUF_VERSION}" ] && error "Failed to get latest version tag from GitHub"
    fi
    curl -fsSL --retry 5 --retry-max-time 90 "https://github.com/bufbuild/buf/releases/download/v${BUF_VERSION}/buf-Linux-$(uname -m).tar.gz" | \
        tar xzf - -C /usr/local --strip-components 1 || \error "Failed to download buf v${BUF_VERSION} tarball"
    chmod 0755 /usr/local/bin/buf /usr/local/bin/protoc-gen-buf-breaking /usr/local/bin/protoc-gen-buf-lint
}

[ "$(id -u)" -eq 0 ] || error 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'

install_from_github
