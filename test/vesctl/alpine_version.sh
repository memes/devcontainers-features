#!/usr/bin/env sh
set -e

# shellcheck disable=SC1091
. alpine-features-test-lib.sh

check "vesctl version is v0.2.46" sh -c "vesctl version | grep '0-2-46'"

reportResults
