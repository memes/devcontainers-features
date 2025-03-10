#!/usr/bin/env sh
set -e

# shellcheck disable=SC1091
. alpine-features-test-lib.sh

check "buf version is v1.49.0" sh -c "buf --version | grep '1.49.0'"

reportResults
