#!/usr/bin/env sh
set -e

# shellcheck disable=SC1091
. alpine-features-test-lib.sh

check "tflint version is v0.55.0" sh -c "tflint --version | grep '0.55.0'"

reportResults
