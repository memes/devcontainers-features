#!/usr/bin/env sh
set -e

case "${VERSION}" in
    latest)
        TOFU_VERSION=""
        ;;
    *)
        # Make sure version is a simple semver, without leading v or trailing debian revision
        TOFU_VERSION="${VERSION#v}"
        TOFU_VERSION="${TOFU_VERSION%%-*}"
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
    type curl >/dev/null 2>/dev/null || error "curl is missing"
    type tar >/dev/null 2>/dev/null || error "tar is missing"
    if [ -z "${TOFU_VERSION}" ]; then
        TOFU_VERSION="$(curl -fsSL --retry 5 --retry-max-time 90 -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/opentofu/opentofu/releases/latest 2>/dev/null | awk -F\" '/tag_name/ {print $4}')"
        TOFU_VERSION="${TOFU_VERSION#v}"
        [ -z "${TOFU_VERSION}" ] && error "Failed to get latest version tag from GitHub"
    fi
    case "$(uname -m)" in
        aarch64)
            tofu_platform=arm64
            ;;
        x86_64)
            tofu_platform=amd64
            ;;
        *)
            error "Unhandled machine arch $(uname -m)"
            ;;
    esac
    curl -fsSL --retry 5 --retry-max-time 90 "https://github.com/opentofu/opentofu/releases/download/v${TOFU_VERSION}/tofu_${TOFU_VERSION}_linux_${tofu_platform}.tar.gz" | \
        tar xzf - -C /usr/local/bin tofu || \
        error "Failed to download OpenTofu ${TOFU_VERSION} tarball"
    chmod 0755 /usr/local/bin/tofu
}

install_apk() {
    grep -q '^@community' /etc/apk/repositories || \
        echo '@community https://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories
    apk --no-cache add "opentofu@community${TOFU_VERSION:+"=~${TOFU_VERSION}"}" || \
        error "Failed to install opentofu from community repo"
}

install_deb() {
    type curl >/dev/null 2>/dev/null || prereqs curl
    type gpg >/dev/null 2>/dev/null || prereqs gnupg2
    type curl >/dev/null 2>/dev/null || error "curl is missing"
    type tar >/dev/null 2>/dev/null || error "tar is missing"
    mkdir -p /etc/apt/keyrings
    curl -fsSLo /etc/apt/keyrings/opentofu.gpg --retry 5 --retry-max-time 90 https://get.opentofu.org/opentofu.gpg || \
        error "Failed to download opentofu GPG key"
    curl -fsSL --retry 5 --retry-max-time 90 https://packages.opentofu.org/opentofu/tofu/gpgkey | gpg --dearmor -o /etc/apt/keyrings/opentofu-repo.gpg || \
        error "Failed to download opentofu repo GPG key"
    chmod 0644 /etc/apt/keyrings/opentofu.gpg /etc/apt/keyrings/opentofu-repo.gpg
    echo "deb [signed-by=/etc/apt/keyrings/opentofu.gpg,/etc/apt/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main" > /etc/apt/sources.list.d/opentofu.list
    chmod 0644 /etc/apt/sources.list.d/opentofu.list
    DEBIAN_FRONTEND=noninteractive apt update
    DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends "tofu${TOFU_VERSION:+"=${TOFU_VERSION}*"}" || \
        error "Failed to install tofu${TOFU_VERSION:+"=${TOFU_VERSION}"}"
    rm -rf /var/lib/apt/lists/*
}

install_fedora() {
    type dnf > /dev/null 2>/dev/null || error "dnf is not installed"
    dnf install -y --setopt=install_weak_deps=False "opentofu${TOFU_VERSION:+"-${TOFU_VERSION}"}" || \
        error "Failed to install opentofu${TOFU_VERSION:+"=${TOFU_VERSION}"}"
    rm -rf /var/cache/dnf/* /var/cache/yum/*
}

install_rpm() {
    type dnf > /dev/null 2>/dev/null || error "dnf is not installed"
    cat > /etc/yum.repos.d/opentofu.repo <<"EOF"
[opentofu]
name=opentofu
baseurl=https://packages.opentofu.org/opentofu/tofu/rpm_any/rpm_any/$basearch
repo_gpgcheck=0
gpgcheck=1
enabled=1
gpgkey=https://get.opentofu.org/opentofu.gpg
       https://packages.opentofu.org/opentofu/tofu/gpgkey
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
EOF
    chmod 0644 /etc/yum.repos.d/opentofu.repo
    dnf install -y --setopt=install_weak_deps=False "tofu${TOFU_VERSION:+"-${TOFU_VERSION}"}" || \
        error "Failed to install tofu${TOFU_VERSION:+"=${TOFU_VERSION}"}"
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
            install_fedora
            ;;
        *rhel*)
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
