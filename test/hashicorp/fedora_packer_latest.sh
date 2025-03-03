#!/usr/bin/env bash
set -e

# shellcheck disable=SC1091
source dev-container-features-test-lib

check "Verify a version of packer is installed" packer -version
check "Verify a version of terraform is not installed" test ! -f /usr/bin/local/terraform -a ! -f /usr/bin/terraform
check "Verify a version of vault is not installed" test ! -f /usr/bin/local/vault -a ! -f /usr/bin/vault
reportResults
