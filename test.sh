#!/usr/bin/env bash
# Unofficial Bash Strict Mode
set -euo pipefail
IFS=$'\n\t'

: <<'END_COMMENT'
Default: run all tests (default)
Optional: list all tests (list)
Optional: run one test (run name)
Optional: create all test files for a given name (create name)
Optional: show help (help)

Files:
* XXX.awkcss
* XXX.input
* XXX.expected
* XXX.expected_error   #can be absent when no error is expected
Produced by tool (in .gitignore)
* XXX.actual
* XXX.actual_error
END_COMMENT

function usage {
    cat <<END_USAGE
Usage: $0 [COMMAND [ARGUMENTS]]

Commands:

    run_all [GREP_FILTER]  (default) run all/some (depending on GREP_FILTER) test-cases
    list [GREP_FILTER]     list all/some (depending on GREP_FILTER) test-cases
    run FILENAME           run specific test-case. (FILENAME is an .awkcss filename)
    show FILENAME          show the output (stdout/stderr) for the specific test-case

    clean                  remove generated files
    create NAME            create all files for one test-case
    help                   show this screen

END_USAGE
    if [[ $# -gt 0 ]]; then
        show_error "🚫" "$@"
    fi
}
function show_error {
    >&2 echo "$@"
}

function is_test_case {
    local f="$1"
    if [[ -f $f ]]; then
        if [[ -f ${f/.awkcss/.input} ]]; then
            if [[ -f ${f/.awkcss/.expected} ]]; then
                return 0
            else
                show_error "🚫 File '$f' exists, but mandatory file '${f/.awkcss/.expected}' not found. Skipping test-case."
                return 3
            fi
        fi
        show_error "🚫 File '$f' exists, but mandatory file '${f/.awkcss/.input}' not found. Skipping test-case."
        return 2
    fi
    show_error "🚫 File '$f' doesn't exist. Skipping test-case."
    return 1
}

function find_tests {
    while IFS= read -r -d '' filename
    do
        if is_test_case "$filename"; then
            echo "${filename}"
        fi
    done <   <(find "$assets" -name "*.awkcss" -print0)
}

function remove_ansi_codes {
    sed $'s/\e\\[[0-9;:]*[a-zA-Z]//g'
}

function show_test {
    declare name="$1"
    if is_test_case "$name"; then
        awkcss -f "$name" "${name/.awkcss/.input}"
    fi
}

function run_test {
    declare name="$1"
    if is_test_case "$name"; then
        awkcss -f "$name" "${name/.awkcss/.input}" 2> "${name/.awkcss/.actual_error}" | remove_ansi_codes > "${name/.awkcss/.actual}" 
        if diff --brief "${name/.awkcss/.actual}" "${name/.awkcss/.expected}" > /dev/null; then
            if [[ -s "${name/.awkcss/.actual_error}" ]]; then
                if [[ -f ${name/.awkcss/.expected_error} ]]; then
                    if diff --brief "${name/.awkcss/.actual_error}" "${name/.awkcss/.expected_error}" > /dev/null; then
                        echo "✅ $name (including _error)"
                    else
                        echo "🆘 $name on stderr"
                    fi
                else
                    echo "🆘 $name on stderr (no .expected_error exists)"
                fi
            else
                echo "✅ $name"
            fi
        else
            echo "🆘 $name on stdout"
        fi
    fi
}

function clean_all_files {
    # The "-delete" primary seems to ignore primaries before the "-or" on macOS
    find "$assets" -name "*.actual" -delete
    find "$assets" -name "*.actual_error" -delete
}

function list_all_tests {
    echo "All test-cases:"
    echo
    for f in $(find_tests | grep "${1:-}"); do
        echo "    $f"
    done
}

function run_all_tests {
    for f in $(find_tests | grep "${1:-}"); do
        run_test "$f"
    done
}

function create_test {
    mkdir -p "$assets/$(dirname "$1")"
    for part in awkcss input expected; do
        touch "$assets/$1.$part"
    done
}

# Setup
assets="assets/tests"
cd "$(dirname "$0")"
# shellcheck disable=SC1091
. awkcss.bash

# Handle arguments
case "${1:-run_all}" in
    run_all | runall | all) run_all_tests "${2:-}";;
    list) list_all_tests "${2:-}";;
    run) if [[ $# -lt 2 ]]; then usage "Provide the name of the test-case"; else run_test "$2"; fi;;
    show) if [[ $# -lt 2 ]]; then usage "Provide the name of the test-case"; else show_test "$2"; fi;;
    clean) clean_all_files;;
    create) if [[ $# -lt 2 ]]; then usage "Provide the name of the to be created test-case"; else create_test "$2"; fi;;
    help|--help|-h) usage;;
    *) usage;;
esac
