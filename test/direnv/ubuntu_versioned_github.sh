#!/usr/bin/env bash
set -e

# shellcheck disable=SC1091
source dev-container-features-test-lib

check "Direnv version is v2.34.0" sh -c "direnv version | grep '2.34.0'"

reportResults
