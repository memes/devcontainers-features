#!/usr/bin/env bash
set -e

# shellcheck disable=SC1091
source dev-container-features-test-lib

check "Verify a version of packer is not installed" test ! -f /usr/bin/local/packer -a ! -f /usr/bin/packer
check "Verify a version of terraform is not installed" test ! -f /usr/bin/local/terraform -a ! -f /usr/bin/terraform
[ -f /usr/bin/vault ] && su -c 'setcap cap_ipc_lock=-ep /usr/bin/vault'
check "Verify a version of vault is installed" sh -c 'vault -version | grep 1.18.4'
reportResults
