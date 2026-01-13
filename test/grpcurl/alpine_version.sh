#!/usr/bin/env sh
set -e

# shellcheck disable=SC1091
. alpine-features-test-lib.sh

check "gRPCurl version is v1.9.2" sh -c "grpcurl -version 2>&1 | grep '1.9.2'"

reportResults
