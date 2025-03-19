#!/usr/bin/env bash
set -e

# shellcheck disable=SC1091
source dev-container-features-test-lib

check "vesctl version is v0.2.46" sh -c "vesctl version | grep '0-2-46'"

reportResults
