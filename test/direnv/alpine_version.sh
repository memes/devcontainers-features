#!/usr/bin/env sh
set -e

# shellcheck disable=SC1091
. alpine-features-test-lib.sh

check "Direnv version is v2.34.0" sh -c "direnv version | grep '2.34.0'"

reportResults
