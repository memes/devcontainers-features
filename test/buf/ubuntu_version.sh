#!/usr/bin/env bash
set -e

# shellcheck disable=SC1091
source dev-container-features-test-lib

check "buf version is v1.49.0" sh -c "buf --version | grep '1.49.0'"

reportResults
