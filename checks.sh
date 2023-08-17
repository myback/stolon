#!/usr/bin/env bash

DEBUG="${DEBUG:-false}"
if [ "${DEBUG}" = "true" ]; then
    set -x
fi

set -eo pipefail

keeper_status() {
    echo $(stolonctl status -f json | jq '.keepers | map(select(.uid == "'${HOSTNAME##*-}'")) | .[0]')
}

livenessProbe() {
    status=$(keeper_status | jq '.healthy')
    if [ "${status}" != "true" ]; then
        return 127
    fi
}

case "$1" in
    livenessProbe) livenessProbe ;;
    *)
        echo "unknown command: $1"
        exit 1
        ;;
esac
