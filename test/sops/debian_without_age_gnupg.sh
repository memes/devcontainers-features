#!/usr/bin/env bash
set -e

# shellcheck disable=SC1091
source dev-container-features-test-lib

check "Verify a version of sops is installed" sops --version
check "Verify a version of age is NOT installed" sh -c '! age --version 2>/dev/null'
check "Verify a version of GnuPG is installed" gpg --version

reportResults
