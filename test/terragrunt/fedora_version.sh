#!/usr/bin/env bash
set -e

# shellcheck disable=SC1091
source dev-container-features-test-lib

check "terragrunt version is v0.73.11" sh -c "terragrunt --version | grep '0.73.11'"

reportResults
