#!/bin/env bash
set -e

./check-env.sh

function patch() {
    local file=$1
    cp hpvm-patches/$file $HPVM_ROOT/hpvm/$file
}

patch lib/Transforms/GenHPVM/GenHPVM.cpp
