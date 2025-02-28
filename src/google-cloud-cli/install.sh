#!/usr/bin/env sh
set -e

case "${VERSION}" in
    latest)
        GCLOUD_VERSION=""
        ;;
    *)
        # Make sure version is a simple semver, without leading v or trailing debian revision
        GCLOUD_VERSION="${VERSION#v}"
        GCLOUD_VERSION="${GCLOUD_VERSION%%-*}"
        ;;
esac

INSTALLFROMTARBALL="${INSTALLFROMTARBALL:-"false"}"
COMPONENTS="${COMPONENTS:-""}"

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

install_from_tarball() {
    # Some gcloud binaries are linked to GNU libc; add gcompat package as necessary
    if grep -q '^ID.*alpine' /etc/os-release && ! apk info -e gcompat; then
        prereqs gcompat
    fi
    type curl >/dev/null 2>/dev/null || prereqs curl
    type tar >/dev/null 2>/dev/null || prereqs tar
    type curl >/dev/null 2>/dev/null || error "curl is missing"
    type tar >/dev/null 2>/dev/null || error "tar is missing"

    sdk_platform="$(uname -m)"
    if [ "${sdk_platform}" = "aarch64" ]; then
        sdk_platform=arm
    fi

    curl -fsSL --retry 5 --retry-max-time 90 "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli${GCLOUD_VERSION:+"-${GCLOUD_VERSION}"}-linux-${sdk_platform}.tar.gz" | \
        tar xzf - -C /opt || \
        error "Failed to download Google Cloud SDK tarball"

    if [ -n "${COMPONENTS}" ]; then
        # shellcheck disable=SC2086
        /opt/google-cloud-sdk/bin/gcloud components install --quiet ${COMPONENTS} || \
            error "Failed to install components ${COMPONENTS}"
    fi
    # shellcheck disable=SC2016
    echo 'PATH="/opt/google-cloud-sdk/bin${PATH:+":${PATH}"}"' > /etc/profile.d/70-google-cloud-sdk.sh
    # shellcheck disable=SC2016
    [ -f /etc/zsh/zshenv ] && \
        echo 'export PATH="/opt/google-cloud-sdk/bin${PATH:+":${PATH}"}"' >> /etc/zsh/zshenv
    # TODO @memes - completion isn't working in zsh
    [ -d "/usr/share/zsh/vendor-completions" ] && \
        ln -s /opt/google-cloud-sdk/completion.zsh.inc /usr/share/zsh/vendor-completions/_google_cloud_sdk
    [ -d "/etc/bash_completion.d" ] && \
        ln -s /opt/google-cloud-sdk/completion.bash.inc /etc/bash_completion.d/google_cloud_sdk
}

install_deb() {
    type curl >/dev/null 2>/dev/null || prereqs curl
    type gpg >/dev/null 2>/dev/null || prereqs gnupg2
    type curl >/dev/null 2>/dev/null || error "curl is missing"
    type tar >/dev/null 2>/dev/null || error "tar is missing"
    mkdir -p /etc/apt/keyrings
    curl -fsSL --retry 5 --retry-max-time 90 https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /etc/apt/keyrings/google-cloud-cli.gpg || \
        error "Failed to install Google Cloud apt key"
    chmod 0644 /etc/apt/keyrings/google-cloud-cli.gpg
    echo "deb [signed-by=/etc/apt/keyrings/google-cloud-cli.gpg] https://packages.cloud.google.com/apt cloud-sdk main" > /etc/apt/sources.list.d/google-cloud-cli.list
    chmod 0644 /etc/apt/sources.list.d/google-cloud-cli.list
    pkgs="google-cloud-cli${GCLOUD_VERSION:+"=${GCLOUD_VERSION}-0"}"
    if [ -n "${COMPONENTS}" ]; then
        for component in ${COMPONENTS}; do
            case "${component}" in
                bigtable)
                    pkgs="${pkgs} google-cloud-cli-bigtable-emulator${GCLOUD_VERSION:+"=${GCLOUD_VERSION}*"}"
                    ;;
                kubectl)
                    pkgs="${pkgs} kubectl${GCLOUD_VERSION:+"=1:${GCLOUD_VERSION}*"}"
                    ;;
                *)
                    pkgs="${pkgs} google-cloud-cli-${component}${GCLOUD_VERSION:+"=${GCLOUD_VERSION}*"}"
                    ;;
            esac
        done
    fi
    DEBIAN_FRONTEND=noninteractive apt update
    # shellcheck disable=SC2086
    DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends ${pkgs} || \
        error "Failed to install ${pkgs}"
    rm -rf /var/lib/apt/lists/*
}

install_rpm() {
    type dnf > /dev/null 2>/dev/null || error "dnf is not installed"
    cat > /etc/yum.repos.d/google-cloud-cli.repo <<"EOF"
[google-cloud-cli]
name=Google Cloud CLI
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el9-$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
    chmod 0644 /etc/yum.repos.d/google-cloud-cli.repo
    pkgs="google-cloud-cli${GCLOUD_VERSION:+"-${GCLOUD_VERSION}"}"
    if [ -n "${COMPONENTS}" ]; then
        for component in ${COMPONENTS}; do
            case "${component}" in
                bigtable)
                    pkgs="${pkgs} google-cloud-cli-bigtable-emulator${GCLOUD_VERSION:+"-${GCLOUD_VERSION}"}"
                    ;;
                kubectl)
                    pkgs="${pkgs} kubectl${GCLOUD_VERSION:+"-${GCLOUD_VERSION}"}"
                    ;;
                *)
                    pkgs="${pkgs} google-cloud-cli-${component}${GCLOUD_VERSION:+"-${GCLOUD_VERSION}"}"
                    ;;
            esac
        done
    fi
    # shellcheck disable=SC2086
    dnf install -y --setopt=install_weak_deps=False ${pkgs} || \
        error "Failed to install ${pkgs}"
    rm -rf /var/cache/dnf/* /var/cache/yum/*
}

[ "$(id -u)" -eq 0 ] || error 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'

if [ "${INSTALLFROMTARBALL}" = "true" ]; then
    install_from_tarball
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
            install_from_tarball
            ;;
    esac
fi
