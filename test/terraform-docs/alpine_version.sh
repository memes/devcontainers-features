#!/usr/bin/env sh
set -e

# shellcheck disable=SC1091
. alpine-features-test-lib.sh

check "terraform-docs version is v0.18.0" sh -c "terraform-docs --version | grep '0.18.0'"

reportResults
