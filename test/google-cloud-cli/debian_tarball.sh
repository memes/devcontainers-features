#!/usr/bin/env bash
set -e

# shellcheck disable=SC1091
source dev-container-features-test-lib

check "Verify a version of gcloud is installed" sh -c "gcloud version | grep 'Google Cloud SDK'"

reportResults
