#!/usr/bin/env bash
set -e

# shellcheck disable=SC1091
source dev-container-features-test-lib

check "Verify a version of gcloud is installed" sh -c "gcloud version | grep 'Google Cloud SDK'"
check "Verify a version of bigtable is installed" sh -c "gcloud components list --format='value(id, state.name)' --filter 'NOT state.name:Not Installed' 2>/dev/null | grep bigtable"
check "Verify a version of kubectl is installed" kubectl version --client=true
check "Verify a version of skaffold is installed" skaffold version

reportResults
