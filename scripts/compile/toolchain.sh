#!/bin/bash -e

SCRIPT_DIR=$(cd `dirname $0`; pwd)
source $SCRIPT_DIR/common.sh

rm -rf $TOOLCHAIN_DIR

$ANDROID_NDK/build/tools/make_standalone_toolchain.py \
    --api $ANDROID_API \
    --install-dir $TOOLCHAIN_DIR \
    --arch $ARCH \
    --stl libc++
