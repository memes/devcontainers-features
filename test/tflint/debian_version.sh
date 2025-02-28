#!/usr/bin/env bash
set -e

# shellcheck disable=SC1091
source dev-container-features-test-lib

check "tflint version is v0.55.0" sh -c "tflint --version | grep '0.55.0'"

reportResults
