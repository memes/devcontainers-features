#!/usr/bin/env sh
set -e

case "${VERSION}" in
    latest)
        GOLANGCILINT_VERSION=""
        ;;
    *)
        # Make sure version is a simple semver, without leading v or trailing debian revision/-pro tag
        GOLANGCILINT_VERSION="${VERSION#v}"
        GOLANGCILINT_VERSION="${GOLANGCILINT_VERSION%%-*}"
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

install_from_github_release() {
    type curl >/dev/null 2>/dev/null || prereqs curl
    type tar >/dev/null 2>/dev/null || prereqs tar
    type awk >/dev/null 2>/dev/null || prereqs gawk
    type awk >/dev/null 2>/dev/null || error "awk is missing"
    type curl >/dev/null 2>/dev/null || error "curl is missing"
    type tar >/dev/null 2>/dev/null || error "tar is missing"

    if [ -z "${GOLANGCILINT_VERSION}" ]; then
        GOLANGCILINT_VERSION="$(curl -fsSL --retry 5 --retry-max-time 90 -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" "https://api.github.com/repos/golangci/golangci-lint/releases/latest" 2>/dev/null | awk -F\" '/tag_name/ {print $4}')"
        GOLANGCILINT_VERSION="${GOLANGCILINT_VERSION#v}"
        [ -z "${GOLANGCILINT_VERSION}" ] && error "Failed to get latest version tag from GitHub"
    fi
    case "$(uname -m)" in
        aarch64)
            golangcilint_platform=arm64
            ;;
        x86_64)
            golangcilint_platform=amd64
            ;;
        *)
            error "Unhandled machine arch $(uname -m)"
            ;;
    esac
    curl -fsSL --retry 5 --retry-max-time 90 "https://github.com/golangci/golangci-lint/releases/download/v${GOLANGCILINT_VERSION}/golangci-lint-${GOLANGCILINT_VERSION}-linux-${golangcilint_platform}.tar.gz" | \
        tar xzf - -C /usr/local/bin --strip-components 1 "golangci-lint-${GOLANGCILINT_VERSION}-linux-${golangcilint_platform}/golangci-lint" || \
        error "Failed to download golangci-lint v${GOLANGCILINT_VERSION} tarball"
    chmod 0755 /usr/local/bin/golangci-lint
}

install_apk() {
    apk --no-cache add "golangci-lint${GOLANGCILINT_VERSION:+"=~${GOLANGCILINT_VERSION}"}" || \
        error "Failed to install golangci-lint${GOLANGCILINT_VERSION:+"=~${GOLANGCILINT_VERSION}"} from repo"
}

[ "$(id -u)" -eq 0 ] || error 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'

if [ "${INSTALLFROMGITHUBRELEASE}" = "true" ] || [ -n "${GOLANGCILINT_VERSION}" ]; then
    install_from_github_release
else
    # shellcheck disable=SC1091
    . /etc/os-release
    case "${ID}" in
        *alpine*)
            install_apk
            ;;
        *)
            install_from_github_release
            ;;
    esac
fi
