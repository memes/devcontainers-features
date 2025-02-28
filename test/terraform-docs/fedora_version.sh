#!/usr/bin/env bash
set -e

# shellcheck disable=SC1091
source dev-container-features-test-lib

check "terraform-docs version is v0.18.0" sh -c "terraform-docs --version | grep '0.18.0'"

reportResults
