#!/usr/bin/env bash
set -e

# shellcheck disable=SC1091
source dev-container-features-test-lib

check "Starship version is v1.22.0" sh -c "starship --version | grep '1.22.0'"

reportResults
