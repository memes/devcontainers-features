#!/usr/bin/env bash
set -e

# shellcheck disable=SC1091
source dev-container-features-test-lib

check "Verify a version of golangci-lint is installed" golangci-lint --version

reportResults
