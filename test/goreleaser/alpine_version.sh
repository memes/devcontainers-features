#!/usr/bin/env sh
set -e

# shellcheck disable=SC1091
. alpine-features-test-lib.sh

check "Verify goreleaser is installed" sh -c "goreleaser --version | grep 'goreleaser: '"
check "Verify goreleaser is v2.6.1" sh -c "goreleaser --version | grep 'GitVersion:[[:space:]]*2\.6\.1'"

reportResults
