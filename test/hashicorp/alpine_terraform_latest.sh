#!/usr/bin/env sh
set -e

# shellcheck disable=SC1091
. alpine-features-test-lib.sh

check "Verify a version of packer is not installed" test ! -f /usr/bin/local/packer -a ! -f /usr/bin/packer
check "Verify a version of terraform is installed" terraform -version
check "Verify a version of vault is not installed" test ! -f /usr/bin/local/vault -a ! -f /usr/bin/vault
reportResults
