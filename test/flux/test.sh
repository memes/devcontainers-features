#!/usr/bin/env bash
set -e

if [ -x /bin/busybox ]; then
    # shellcheck disable=SC1091
    . alpine-features-test-lib.sh
else
    # shellcheck disable=SC1091
    source dev-container-features-test-lib
fi

check "Verify a version of flux is installed" flux version --client

reportResults
