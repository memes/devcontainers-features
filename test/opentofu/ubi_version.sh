#!/usr/bin/env bash
set -e

# shellcheck disable=SC1091
source dev-container-features-test-lib

check "Tofu version is v1.8.8" sh -c "tofu version | grep '1.8.8'"

reportResults
