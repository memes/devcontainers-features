#!/usr/bin/env bash
set -e

# shellcheck disable=SC1091
source dev-container-features-test-lib

check "Talisman version is v1.31.0" sh -c "talisman --version | grep '1.31.0'"

reportResults
