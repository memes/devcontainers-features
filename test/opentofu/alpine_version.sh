#!/usr/bin/env sh
set -e

# shellcheck disable=SC1091
. alpine-features-test-lib.sh

check "Tofu version is v1.7.2" sh -c "tofu version | grep '1.7.2'"

reportResults
