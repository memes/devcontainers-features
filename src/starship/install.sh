#!/usr/bin/env sh
set -e

case "${VERSION}" in
    latest)
        STARSHIP_VERSION=""
        ;;
    *)
        # Make sure version is a simple semver, without leading v or trailing debian revision
        STARSHIP_VERSION="${VERSION#v}"
        STARSHIP_VERSION="${STARSHIP_VERSION%%-*}"
        ;;
esac

INSTALLFROMGITHUBRELEASE="${INSTALLFROMGITHUBRELEASE:-"false"}"

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
    if [ -z "${STARSHIP_VERSION}" ]; then
        STARSHIP_VERSION="$(curl -fsSL --retry 5 --retry-max-time 90 -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/starship/starship/releases/latest 2>/dev/null | awk -F\" '/tag_name/ {print $4}')"
        STARSHIP_VERSION="${STARSHIP_VERSION#v}"
        [ -z "${STARSHIP_VERSION}" ] && error "Failed to get latest version tag from GitHub"
    fi
    curl -fsSL --retry 5 --retry-max-time 90 "https://github.com/starship/starship/releases/download/v${STARSHIP_VERSION}/starship-$(uname -m)-unknown-linux-musl.tar.gz" | \
        tar xzf - -C /usr/local/bin || \
        error "Failed to download and extract starship ${STARSHIP_VERSION} tarball"
}

install_apk() {
    apk --no-cache add "starship${STARSHIP_VERSION:+"=~${STARSHIP_VERSION}"}" || \
        error "Failed to install starship${STARSHIP_VERSION:+"=~${STARSHIP_VERSION}"} from repo"
}

[ "$(id -u)" -eq 0 ] || error 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'

if [ "${INSTALLFROMGITHUBRELEASE}" = "true" ] || [ -n "${STARSHIP_VERSION}" ]; then
    install_from_github
else
    # shellcheck disable=SC1091
    . /etc/os-release
    case "${ID}" in
        *alpine*)
            install_apk
            ;;
        *)
            install_from_github
            ;;
    esac
fi
