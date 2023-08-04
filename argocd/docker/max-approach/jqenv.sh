#!/bin/bash

parse_params() {
    while :; do
            case "${1-}" in
            --arg )
                    IFS=','
                    read -r -a VAR_ARRAY <<< "${2-}"
                    for ELEMENT in "${VAR_ARRAY[@]}"
                    do
                        export "$ELEMENT"
                    done
                    IFS=' '
                    shift
                    ;;
            -?*) die "Unknown option: $1" ;;
            *) break ;;
            esac
            shift
    done

    unset HOSTNAME
    unset PWD
    unset HOME
    unset TERM
    unset SHLVL
    unset PATH
    unset -
    /usr/bin/jq -n env
}

parse_params "$@"
