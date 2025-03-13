#!/usr/bin/env sh
set -e

# shellcheck disable=SC1091
. alpine-features-test-lib.sh

check "sops version is v3.9.3" sh -c "sops --version | grep '3.9.3'"

reportResults
