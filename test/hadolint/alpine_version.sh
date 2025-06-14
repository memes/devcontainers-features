#!/usr/bin/env sh
set -e

# shellcheck disable=SC1091
. alpine-features-test-lib.sh

check "hadolint version is v2.11.0" sh -c "hadolint --version | grep '2.11.0'"

reportResults
