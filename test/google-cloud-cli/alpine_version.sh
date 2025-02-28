#!/usr/bin/env sh
set -e

# shellcheck disable=SC1091
. alpine-features-test-lib.sh

check "Google Cloud SDK version is 509.0.0" sh -c "gcloud version | grep 'Google Cloud SDK 509.0.0'"

reportResults
