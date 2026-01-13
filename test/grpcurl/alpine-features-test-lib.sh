#!/usr/bin/env sh
# shellcheck disable=SC3037 # alpine (busybox) shell supports echo -e
# TODO @memes - upstream lib requires bash, so stub out check function here and
# source in scenario files.

FAILED=""
check() {
    LABEL=$1
    shift
    echo -e "\n"
    echo -e "🔄 Testing '$LABEL'"
    if "$@"; then
        echo -e "\n"
        echo "✅  Passed '$LABEL'!"
        return 0
    else
        echo -e "\n"
        echo "❌ $LABEL check failed." 1>&2
        FAILED="$FAILED${FAILED:+" "}$LABEL"
        return 1
    fi
}

reportResults() {
    if [ -n "${FAILED}" ]; then
        echo -e "\n"
        echo "💥  Failed tests: ${FAILED}"
        exit 1
    else
        echo -e "\n"
        echo -e "Test Passed!"
        exit 0
    fi
}
