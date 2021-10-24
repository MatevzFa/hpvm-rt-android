#!/usr/bin/env bash
set -e

function check_var() {
    local name=$1

    if [[ -z ${!name} ]]; then
        echo "Variable $name not set."
        exit 1
    fi
}

# Check required variables
check_var ANDROID_NDK
check_var HPVM_ROOT
check_var HPVM_BUILD
check_var TARGET
check_var LIB_INSTALL_PATH
check_var INCLUDE_INSTALL_PATH
