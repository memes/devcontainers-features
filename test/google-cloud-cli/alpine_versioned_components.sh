#!/usr/bin/env sh
set -e

# shellcheck disable=SC1091
. alpine-features-test-lib.sh

check "Google Cloud SDK version is 509.0.0" sh -c "gcloud version | grep 'Google Cloud SDK 509.0.0'"
check "Verify a version of bigtable is installed" sh -c "gcloud components list --format='value(id, state.name)' --filter 'NOT state.name:Not Installed' 2>/dev/null | grep bigtable"
check "Verify a version of kubectl is installed" kubectl version --client=true
check "Verify a version of skaffold is installed" skaffold version

reportResults
