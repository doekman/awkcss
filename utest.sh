#!/usr/bin/env bash
# Unofficial Bash Strict Mode
set -euo pipefail
IFS=$'\n\t'

function find_tests {
    while IFS= read -r -d '' filename
    do
        echo "${filename}"
    done <   <(find "$assets" -name "*.awk" -print0)
}

function run_test {
    echo "" | awk -f ./utest_1.awk -f "$1" -f ./utest_2.awk
}

function run_all_tests {
    for f in $(find_tests | grep "${1:-}"); do
        run_test "$f"
    done
}


assets="assets/utest"
cd "$(dirname "$0")"

run_all_tests
