#!/usr/bin/env sh
set -e

# shellcheck disable=SC1091
. alpine-features-test-lib.sh

check "gcrane version is v0.20.5" sh -c "gcrane version | grep '0.20.5'"

reportResults
