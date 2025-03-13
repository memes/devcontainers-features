#!/usr/bin/env bash
set -e

if [ -x /bin/busybox ]; then
    # shellcheck disable=SC1091
    . alpine-features-test-lib.sh
else
    # shellcheck disable=SC1091
    source dev-container-features-test-lib
fi

check "Verify a version of sops is installed" sops --version
# shellcheck disable=SC1091
. /etc/os-release
case "${ID}" in
    *rhel*)
        check "Verify a version of age is NOT installed" sh -c '! age --version 2>/dev/null'
        ;;
    *)
        check "Verify a version of age is installed " age --version
        ;;
esac
check "Verify a version of GnuPG is installed " gpg --version

reportResults
