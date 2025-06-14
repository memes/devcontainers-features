#!/usr/bin/env bash
set -e

# shellcheck disable=SC1091
source dev-container-features-test-lib

check "hadolint version is v2.11.0" sh -c "hadolint --version | grep '2.11.0'"

reportResults
