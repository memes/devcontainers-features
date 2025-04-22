#!/usr/bin/env sh
set -e

case "${VERSION}" in
    latest)
        GORELEASER_VERSION=""
        ;;
    *)
        # Make sure version is a simple semver, without leading v or trailing debian revision/-pro tag
        GORELEASER_VERSION="${VERSION#v}"
        GORELEASER_VERSION="${GORELEASER_VERSION%%-*}"
        ;;
esac
PRO="${PRO:-"false"}"
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

    GORELEASER_TARGET="goreleaser"
    if [ "${PRO}" = "true" ]; then
        GORELEASER_TARGET="goreleaser-pro"
        case "${GORELEASER_VERSION}" in
            *-pro)
                ;;
            *)
                GORELEASER_VERSION="${GORELEASER_VERSION:+"${GORELEASER_VERSION}-pro"}"
                ;;
        esac
    fi
    if [ -z "${GORELEASER_VERSION}" ]; then
        GORELEASER_VERSION="$(curl -fsSL --retry 5 --retry-max-time 90 -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" "https://api.github.com/repos/goreleaser/${GORELEASER_TARGET}/releases/latest" 2>/dev/null | awk -F\" '/tag_name/ {print $4}')"
        GORELEASER_VERSION="${GORELEASER_VERSION#v}"
        [ -z "${GORELEASER_VERSION}" ] && error "Failed to get latest version tag from GitHub"
    fi
    case "$(uname -m)" in
        aarch64)
            goreleaser_platform=arm64
            ;;
        x86_64)
            goreleaser_platform=x86_64
            ;;
        *)
            error "Unhandled machine arch $(uname -m)"
            ;;
    esac
    curl -fsSL --retry 5 --retry-max-time 90 "https://github.com/goreleaser/${GORELEASER_TARGET}/releases/download/v${GORELEASER_VERSION}/${GORELEASER_TARGET}_Linux_${goreleaser_platform}.tar.gz" | \
        tar xzf - -C /usr/local/bin goreleaser || \error "Failed to download ${GORELEASER_TARGET} v${GORELEASER_VERSION} tarball"
    chmod 0755 /usr/local/bin/goreleaser
}

install_deb() {
    echo "deb [trusted=yes] https://repo.goreleaser.com/apt/ /" > /etc/apt/sources.list.d/goreleaser.list
    chmod 0644 /etc/apt/sources.list.d/goreleaser.list
    GORELEASER_TARGET="goreleaser"
    if [ "${PRO}" = "true" ]; then
        GORELEASER_TARGET="goreleaser-pro"
    fi
    DEBIAN_FRONTEND=noninteractive apt update
    DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends "${GORELEASER_TARGET}${GORELEASER_VERSION:+"=${GORELEASER_VERSION}*"}" || \
        error "Failed to install ${GORELEASER_TARGET}${GORELEASER_VERSION:+"=${GORELEASER_VERSION}*"}"
    rm -rf /var/lib/apt/lists/*
}

install_rpm() {
    type dnf > /dev/null 2>/dev/null || error "dnf is not installed"
    cat > /etc/yum.repos.d/goreleaser.repo <<"EOF"
[goreleaser]
name=GoReleaser
baseurl=https://repo.goreleaser.com/yum/
enabled=1
gpgcheck=0
EOF
    chmod 0644 /etc/yum.repos.d/goreleaser.repo
    GORELEASER_TARGET="goreleaser"
    GORELEASER_EXCLUDE="goreleaser-pro"
    if [ "${PRO}" = "true" ]; then
        GORELEASER_TARGET="goreleaser-pro"
        GORELEASER_EXCLUDE="goreleaser"
    fi
    dnf install -y --setopt=install_weak_deps=False --exclude "${GORELEASER_EXCLUDE}" "${GORELEASER_TARGET}${GORELEASER_VERSION:+"-${GORELEASER_VERSION}*"}" || \
        error "Failed to install ${GORELEASER_TARGET}${GORELEASER_VERSION:+"-${GORELEASER_VERSION}*"}"
    rm -rf /var/cache/dnf/* /var/cache/yum/*
}

[ "$(id -u)" -eq 0 ] || error 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'

if [ "${INSTALLFROMGITHUBRELEASE}" = "true" ]; then
    install_from_github_release
else
    # shellcheck disable=SC1091
    . /etc/os-release
    case "${ID}" in
        *rhel*|*fedora*)
            install_rpm
            ;;
        *debian*|*ubuntu*)
            install_deb
            ;;
        *)
            install_from_github_release
            ;;
    esac
fi
