#!/usr/bin/env sh
set -e

# shellcheck disable=SC1091
. alpine-features-test-lib.sh

check "flux version is v2.5.0" sh -c "flux version --client | grep '2.5.0'"

reportResults
