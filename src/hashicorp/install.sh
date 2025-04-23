#!/usr/bin/env sh
set -e

# Make sure versions are simple semvers, without leading v or trailing debian revision
PACKER_VERSION="${PACKER#v}"
PACKER_VERSION="${PACKER_VERSION%%-*}"
TERRAFORM_VERSION="${TERRAFORM#v}"
TERRAFORM_VERSION="${TERRAFORM_VERSION%%-*}"
VAULT_VERSION="${VAULT#v}"
VAULT_VERSION="${VAULT_VERSION%%-*}"
INSTALLBINARIES="${INSTALLBINARIES:-"false"}"

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

download_and_verify_zip() {
    type curl >/dev/null 2>/dev/null || prereqs curl
    type gpg >/dev/null 2>/dev/null || prereqs gnupg2
    type unzip >/dev/null 2>/dev/null || prereqs unzip
    type awk >/dev/null 2>/dev/null || prereqs gawk
    type awk >/dev/null 2>/dev/null || error "awk is missing"
    type curl >/dev/null 2>/dev/null || error "curl is missing"
    type gpg >/dev/null 2>/dev/null || error "gpg is missing"
    type unzip >/dev/null 2>/dev/null || error "unzip is missing"
    hashi_product="$1"
    hashi_version="$2"
    target_dir="$3"

    if [ "${hashi_version}" = "latest" ]; then
        hashi_version="$(curl -fsSL --retry 5 --retry-max-time 90 -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" "https://api.github.com/repos/hashicorp/${hashi_product}/releases/latest" 2>/dev/null | awk -F\" '/tag_name/ {print $4}')"
        hashi_version="${hashi_version#v}"
        [ -z "${hashi_version}" ] && error "Failed to get latest ${hashi_product} version tag from GitHub"
    fi
    case "$(uname -m)" in
        aarch64)
            hashi_platform=arm64
            ;;
        x86_64)
            hashi_platform=amd64
            ;;
        *)
            error "Unhandled machine arch $(uname -m)"
            ;;
    esac
    curl -fsSL --remote-name-all --output-dir "${target_dir}" --retry 5 --retry-max-time 90 \
        "https://releases.hashicorp.com/${hashi_product}/${hashi_version}/${hashi_product}_${hashi_version}_SHA256SUMS" \
        "https://releases.hashicorp.com/${hashi_product}/${hashi_version}/${hashi_product}_${hashi_version}_SHA256SUMS.72D7468F.sig" \
        "https://releases.hashicorp.com/${hashi_product}/${hashi_version}/${hashi_product}_${hashi_version}_linux_${hashi_platform}.zip" || \
            error "Failed to download ${hashi_product} ${hashi_version} files"
    gpg --homedir "${target_dir}" --receive-keys 34365D9472D7468F || error "Failed to import HashiCorp GPG key"
    gpg --homedir "${target_dir}" \
        --verify "${tmp_dir}/${hashi_product}_${hashi_version}_SHA256SUMS.72D7468F.sig" \
        "${tmp_dir}/${hashi_product}_${hashi_version}_SHA256SUMS" || \
            error "Failed to verify ${hashi_product} files"
    (cd "${tmp_dir}" && sha256sum --ignore-missing --check "${hashi_product}_${hashi_version}_SHA256SUMS") || \
        error "Failed to verify checksum"
    unzip "${tmp_dir}/${hashi_product}_${hashi_version}_linux_${hashi_platform}.zip" -d "${tmp_dir}" || \
        error "Failed to extract from ${hashi_product} ${hashi_version} zip file"
}

install_packer_binary() {
    tmp_dir="$(mktemp -d packerXXX)"
    download_and_verify_zip packer "${PACKER_VERSION}" "${tmp_dir}"
    mv "${tmp_dir}/packer" /usr/local/bin/packer
    rm -rf "${tmp_dir}"
    chmod 0755 /usr/local/bin/packer
}

install_terraform_binary() {
    tmp_dir="$(mktemp -d terraformXXX)"
    download_and_verify_zip terraform "${TERRAFORM_VERSION}" "${tmp_dir}"
    mv "${tmp_dir}/terraform" /usr/local/bin/terraform
    rm -rf "${tmp_dir}"
    chmod 0755 /usr/local/bin/terraform
}

install_vault_binary() {
    # shellcheck disable=SC1091
    . /etc/os-release
    case "${ID}" in
        *alpine*)
            if grep -q '^ID.*alpine' /etc/os-release && ! apk info -e libcap-setcap; then
                prereqs libcap-setcap || error "Failed to install libcap-setcap package"
            fi
            ;;
        *)
            ;;
    esac
    tmp_dir="$(mktemp -d vaultXXX)"
    download_and_verify_zip vault "${VAULT_VERSION}" "${tmp_dir}"
    mv "${tmp_dir}/vault" /usr/local/bin/vault
    rm -rf "${tmp_dir}"
    chmod 0755 /usr/local/bin/vault
    if type setcap >/dev/null 2>/dev/null; then
        setcap cap_ipc_lock=+ep /usr/local/bin/vault
    fi
}

install_deb() {
    type curl >/dev/null 2>/dev/null || prereqs curl
    type gpg >/dev/null 2>/dev/null || prereqs gnupg2
    type curl >/dev/null 2>/dev/null || error "curl is missing"
    type gpg >/dev/null 2>/dev/null || error "gpg is missing"
    mkdir -p /etc/apt/keyrings
    curl -fsSL --retry 5 --retry-max-time 90 https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /etc/apt/keyrings/hashicorp.gpg || \
        error "Failed to install HashiCorp apt key"
    chmod 0644 /etc/apt/keyrings/hashicorp.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list
    chmod 0644 /etc/apt/sources.list.d/hashicorp.list
    pkgs=""
    case "${PACKER_VERSION}" in
        latest)
            pkgs="${pkgs}${pkgs:+" "}packer"
            ;;
        "")
            ;;
        *)
            pkgs="${pkgs}${pkgs:+" "}packer=${PACKER_VERSION}*"
            ;;
    esac
    case "${TERRAFORM_VERSION}" in
        latest)
            pkgs="${pkgs}${pkgs:+" "}terraform"
            ;;
        "")
            ;;
        *)
            pkgs="${pkgs}${pkgs:+" "}terraform=${TERRAFORM_VERSION}*"
            ;;
    esac
    case "${VAULT_VERSION}" in
        latest)
            pkgs="${pkgs}${pkgs:+" "}vault"
            ;;
        "")
            ;;
        *)
            pkgs="${pkgs}${pkgs:+" "}vault=${VAULT_VERSION}*"
            ;;
    esac
    DEBIAN_FRONTEND=noninteractive apt update
    # shellcheck disable=SC2086
    DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends ${pkgs} || \
        error "Failed to install ${pkgs}"
    rm -rf /var/lib/apt/lists/*
}

install_rpm() {
    type dnf > /dev/null 2>/dev/null || error "dnf is not installed"
    case "${ID}" in
        *fedora*)
            dnf config-manager addrepo --from-repofile https://rpm.releases.hashicorp.com/fedora/hashicorp.repo || \
                error "Failed to add HashiCorp fedora repo"
            ;;
        *)
            dnf config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo || \
                error "Failed to add HashiCorp RHEL repo"
            ;;
    esac

    pkgs=""
    case "${PACKER_VERSION}" in
        latest)
            pkgs="${pkgs}${pkgs:+" "}packer"
            ;;
        "")
            ;;
        *)
            pkgs="${pkgs}${pkgs:+" "}packer-${PACKER_VERSION}*"
            ;;
    esac
    case "${TERRAFORM_VERSION}" in
        latest)
            pkgs="${pkgs}${pkgs:+" "}terraform"
            ;;
        "")
            ;;
        *)
            pkgs="${pkgs}${pkgs:+" "}terraform-${TERRAFORM_VERSION}*"
            ;;
    esac
    case "${VAULT_VERSION}" in
        latest)
            pkgs="${pkgs}${pkgs:+" "}vault"
            ;;
        "")
            ;;
        *)
            pkgs="${pkgs}${pkgs:+" "}vault-${VAULT_VERSION}*"
            ;;
    esac
    # shellcheck disable=SC2086
    dnf install -y --setopt=install_weak_deps=False ${pkgs} || \
        error "Failed to install ${pkgs}"
    rm -rf /var/cache/dnf/* /var/cache/yum/*
}

[ "$(id -u)" -eq 0 ] || error 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'

if [ -z "${PACKER_VERSION}" ] && [ -z "${TERRAFORM_VERSION}" ] && [ -z "${VAULT}" ]; then
    echo "No HashiCorp tools to install"
    exit 0
fi

if [ "${INSTALLBINARIES}" = "true" ]; then
    if [ -n "${PACKER_VERSION}" ]; then
        install_packer_binary
    fi
    if [ -n "${TERRAFORM_VERSION}" ]; then
        install_terraform_binary
    fi
    if [ -n "${VAULT_VERSION}" ]; then
        install_vault_binary
    fi
else
    # shellcheck disable=SC1091
    . /etc/os-release
    case "${ID}" in
        *rhel*)
            install_rpm
            ;;
        *debian*|*ubuntu*)
            install_deb
            ;;
        *)
            if [ -n "${PACKER_VERSION}" ]; then
                install_packer_binary
            fi
            if [ -n "${TERRAFORM_VERSION}" ]; then
                install_terraform_binary
            fi
            if [ -n "${VAULT_VERSION}" ]; then
                install_vault_binary
            fi
            ;;
    esac
fi
