#!/usr/bin/env sh
set -e

# shellcheck disable=SC1091
. alpine-features-test-lib.sh

check "Verify goreleaser pro is installed" sh -c "goreleaser --version | grep 'goreleaser-pro: '"
check "Verify goreleaser pro is v2.6.1" sh -c "goreleaser --version | grep 'GitVersion:[[:space:]]*2\.6\.1'"

reportResults
