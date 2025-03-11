#!/usr/bin/env bash
set -e

# shellcheck disable=SC1091
source dev-container-features-test-lib

check "Verify golangci-lint is v1.64.5" sh -c "golangci-lint --version | grep '1\.64\.5'"

reportResults
