#!/usr/bin/env bash
set -e

# shellcheck disable=SC1091
source dev-container-features-test-lib

check "gRPCurl version is v1.9.2" sh -c "grpcurl -version 2>&1 | grep '1.9.2'"

reportResults
