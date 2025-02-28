#!/usr/bin/env sh
set -e

# shellcheck disable=SC1091
. alpine-features-test-lib.sh

check "Starship version is v1.18.2" sh -c "starship --version | grep '1.18.2'"

reportResults
