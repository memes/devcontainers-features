#!/usr/bin/env sh
set -e

# shellcheck disable=SC1091
. alpine-features-test-lib.sh

check "Verify a version of goreleaser pro is installed" sh -c "goreleaser --version | grep 'goreleaser-pro:'"

reportResults
