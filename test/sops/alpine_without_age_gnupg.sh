#!/usr/bin/env sh
set -e

# shellcheck disable=SC1091
. alpine-features-test-lib.sh

check "Verify a version of sops is installed" sops --version
check "Verify a version of age is NOT installed" sh -c '! age --version 2>/dev/null'
check "Verify a version of GnuPG is installed " gpg --version

reportResults
