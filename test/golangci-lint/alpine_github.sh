#!/usr/bin/env bash
set -e

# shellcheck disable=SC1091
. alpine-features-test-lib.sh

check "Verify a version of golangci-lint is installed" golangci-lint --version

reportResults
