#!/usr/bin/env sh
set -e

# shellcheck disable=SC1091
. alpine-features-test-lib.sh

check "terragrunt version is v0.73.11" sh -c "terragrunt --version | grep '0.73.11'"

reportResults
