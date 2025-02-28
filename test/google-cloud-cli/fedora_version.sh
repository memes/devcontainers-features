#!/usr/bin/env bash
set -e

# shellcheck disable=SC1091
source dev-container-features-test-lib

check "Google Cloud SDK version is 509.0.0" sh -c "gcloud version | grep 'Google Cloud SDK 509.0.0'"

reportResults
