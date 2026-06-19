#!/usr/bin/env bash
#
# UBI images are special and cannot use common.sh without customization and branching.
set -e

# shellcheck disable=SC1091
source dev-container-features-test-lib

check "Verify a version of gcloud is installed" sh -c "gcloud version | grep 'Google Cloud SDK'"
check "Verify a version of talisman is installed" talisman --version
check "Verify a version of tflint is installed" tflint --version
check "Verify a version of packer is installed" /usr/bin/packer -version
check "Verify a version of terraform is installed" terraform -version
[ -f /usr/bin/vault ] && setcap cap_ipc_lock=-ep /usr/bin/vault
check "Verify a version of vault is installed" vault -version
check "Verify a version of buf is installed" buf --version
check "Verify a version of goreleaser is installed" goreleaser --version
check "Verify a version of vesctl is installed " vesctl version
check "Verify a version of flux is installed " flux version --client
check "Verify a version of hadolint is installed " hadolint --version
check "Verify a version of gcrane is installed " gcrane version
check "Verify a version of gRPCurl is installed " grpcurl -version

reportResults
