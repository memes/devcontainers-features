#!/usr/bin/env sh
set -e

# shellcheck disable=SC1091
. alpine-features-test-lib.sh

check "Talisman version is v1.31.0" sh -c "talisman --version | grep '1.31.0'"

reportResults
