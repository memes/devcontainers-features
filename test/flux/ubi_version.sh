#!/usr/bin/env bash
set -e

# shellcheck disable=SC1091
source dev-container-features-test-lib

check "flux version is v2.5.0" sh -c "flux version --client | grep '2.5.0'"

reportResults
