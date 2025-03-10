#!/usr/bin/env bash
set -e

# shellcheck disable=SC1091
source dev-container-features-test-lib

check "Verify a version of goreleaser is installed" sh -c "goreleaser --version | grep 'goreleaser:'"

reportResults
