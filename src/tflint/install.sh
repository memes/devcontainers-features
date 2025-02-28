#!/usr/bin/env sh
set -e

case "${VERSION}" in
    latest)
        TFLINT_VERSION=""
        ;;
    *)
        # Make sure version is a simple semver, without leading v or trailing debian revision
        TFLINT_VERSION="${VERSION#v}"
        TFLINT_VERSION="${TFLINT_VERSION%%-*}"
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
    type unzip >/dev/null 2>/dev/null || prereqs unzip
    type curl >/dev/null 2>/dev/null || error "curl is missing"
    type unzip >/dev/null 2>/dev/null || error "unzip is missing"
    if [ -z "${TFLINT_VERSION}" ]; then
        TFLINT_VERSION="$(curl -fsSL -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/terraform-linters/tflint/releases/latest 2>/dev/null | awk -F\" '/tag_name/ {print $4}')"
        TFLINT_VERSION="${TFLINT_VERSION#v}"
        [ -z "${TFLINT_VERSION}" ] && error "Faild to get latest version tag from GitHub"
    fi
    case "$(uname -m)" in
        aarch64)
            tflint_platform=arm64
            ;;
        x86_64)
            tflint_platform=amd64
            ;;
        *)
            error "Unhandled machine arch $(uname -m)"
            ;;
    esac
    tmp_dir="$(mktemp -d tflintXXX)"
    curl -fsSLo "${tmp_dir}/tflint.zip" "https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_${tflint_platform}.zip" || \
        error "Failed to download tflint ${TFLINT_VERSION} zip file"
    unzip "${tmp_dir}/tflint.zip" -d "${tmp_dir}" || \
        error "Failed to extract from tflint ${TFLINT_VERSION} zip file"
    mv "${tmp_dir}/tflint" /usr/local/bin/tflint
    rm -rf "${tmp_dir}"
    chmod 0755 /usr/local/bin/tflint
}

install_apk() {
    apk --no-cache add "tflint${TFLINT_VERSION:+"=~${TFLINT_VERSION}"}" || \
        error "Failed to install tflint${TFLINT_VERSION:+"=~${TFLINT_VERSION}"} from repo"
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
        *)
            install_from_github
            ;;
    esac
fi
