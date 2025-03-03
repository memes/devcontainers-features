#!/usr/bin/env bash
set -e

# shellcheck disable=SC1091
. alpine-features-test-lib.sh

check "Verify a version of packer is not installed" test ! -f /usr/bin/local/packer -a ! -f /usr/bin/packer
check "Verify a version of terraform is not installed" test ! -f /usr/bin/local/terraform -a ! -f /usr/bin/terraform
[ -f /usr/local/bin/vault ] && sudo setcap cap_ipc_lock=-ep /usr/local/bin/vault
check "Verify a version of vault is installed" sh -c 'vault -version | grep 1.18.4'
reportResults
