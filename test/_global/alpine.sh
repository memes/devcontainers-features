#!/usr/bin/env sh
set -e

# shellcheck disable=SC1091
. alpine-features-test-lib.sh

check "Verify a version of direnv is installed" direnv version
check "Verify a version of gcloud is installed" sh -c "gcloud version | grep 'Google Cloud SDK'"
check "Verify a version of tofu is installed" tofu version
check "Verify a version of starship is installed" starship --version
check "Verify a version of talisman is installed" talisman --version
check "Verify a version of terraform-docs is installed" terraform-docs --version
check "Verify a version of terragrunt is installed" terragrunt --version
check "Verify a version of tflint is installed" tflint --version
check "Verify a version of packer is installed" packer -version
check "Verify a version of terraform is installed" terraform -version
[ -f /usr/local/bin/vault ] && sudo setcap cap_ipc_lock=-ep /usr/local/bin/vault
check "Verify a version of vault is installed" vault -version
check "Verify a version of buf is installed" buf --version
check "Verify a version of goreleaser is installed" goreleaser --version
check "Verify a version of golangci-lint is installed" golangci-lint --version
reportResults
