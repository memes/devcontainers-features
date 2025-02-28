#!/usr/bin/env sh
set -e

case "${VERSION}" in
    latest)
        DIRENV_VERSION=""
        ;;
    *)
        # Make sure version is a simple semver, without leading v or trailing debian revision
        DIRENV_VERSION="${VERSION#v}"
        DIRENV_VERSION="${DIRENV_VERSION%%-*}"
        ;;
esac

INSTALLFROMGITHUBRELEASE="${INSTALLFROMGITHUBRELEASE:-"false"}"

error() {
    echo "ERROR: $*" >&2
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
    if [ -z "${DIRENV_VERSION}" ]; then
        DIRENV_VERSION="$(curl -fsSL -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/direnv/direnv/releases/latest 2>/dev/null | awk -F\" '/tag_name/ {print $4}')"
        DIRENV_VERSION="${DIRENV_VERSION#v}"
        [ -z "${DIRENV_VERSION}" ] && error "Failed to get latest version tag from GitHub"
    fi
    case "$(uname -m)" in
        aarch64)
            direnv_platform=arm64
            ;;
        x86_64)
            direnv_platform=amd64
            ;;
        *)
            error "Unhandled machine arch $(uname -m)"
            ;;
    esac
    curl -fsSLo /usr/local/bin/direnv "https://github.com/direnv/direnv/releases/download/v${DIRENV_VERSION}/direnv.linux-${direnv_platform}" || \
        error "Failed to download direnv v${DIRENV_VERSION} binary from GitHub"
    chmod 0755 /usr/local/bin/direnv
}

install_apk() {
    apk --no-cache add "direnv${DIRENV_VERSION:+"=~${DIRENV_VERSION}"}" || \
        error "Failed to install direnv${DIRENV_VERSION:+"=~${DIRENV_VERSION}"} from repo"
}

install_deb() {
    DEBIAN_FRONTEND=noninteractive apt update
    DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends "direnv${DIRENV_VERSION:+"=${DIRENV_VERSION}*"}" || \
        error "Failed to install direnv${DIRENV_VERSION:+"=${DIRENV_VERSION}"}"
    rm -rf /var/lib/apt/lists/*
}

install_rpm() {
    type dnf > /dev/null 2>/dev/null || error "dnf is not installed"
    dnf install -y --setopt=install_weak_deps=False "direnv${DIRENV_VERSION:+"-${DIRENV_VERSION}"}" || \
        error "Failed to install direnv${DIRENV_VERSION:+"=${DIRENV_VERSION}"}"
    rm -rf /var/cache/dnf/* /var/cache/yum/*
}

[ "$(id -u)" -eq 0 ] || error 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'

if [ "${INSTALLFROMGITHUBRELEASE}" = "true" ]; then
    install_from_github
else
    # shellcheck disable=SC1091
    . /etc/os-release
    case "${ID}" in
        *alpine*)
            install_apk
            ;;
        *fedora*)
            install_rpm
            ;;
        *debian*|*ubuntu*)
            install_deb
            ;;
        *)
            install_from_github
            ;;
    esac
fi
