#!/usr/bin/env bash
set -e

# shellcheck disable=SC1091
source dev-container-features-test-lib

check "gcrane version is v0.20.5" sh -c "gcrane version | grep '0.20.5'"

reportResults
