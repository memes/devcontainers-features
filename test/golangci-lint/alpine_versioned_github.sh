#!/usr/bin/env sh
set -e

# shellcheck disable=SC1091
. alpine-features-test-lib.sh

check "Verify golangci-lint is v1.64.5" sh -c "golangci-lint --version | grep '1\.64\.5'"

reportResults
