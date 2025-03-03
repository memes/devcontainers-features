#!/usr/bin/env bash
set -e

# shellcheck disable=SC1091
source dev-container-features-test-lib

check "Verify a version of packer is not installed" test ! -f /usr/bin/local/packer -a ! -f /usr/bin/packer
check "Verify a version of terraform is installed" sh -c 'terraform -version | grep 1.10.5'
check "Verify a version of vault is not installed" test ! -f /usr/bin/local/vault -a ! -f /usr/bin/vault
reportResults
