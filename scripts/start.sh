#!/bin/bash -ex

ROOTDIR=$PWD
VERSION_NAME=$($ROOTDIR/scripts/version.sh)

# compile
rm -rf $ROOTDIR/build/compiled
$ROOTDIR/scripts/compile/all.sh

# create aar
cd $ROOTDIR/lib
./gradlew clean createAAR --project-prop VERSION_NAME="$VERSION_NAME"
cd $ROOTDIR

printf "\n\n\n\n\n\t\t\tCompiled Version: \x1B[32m${VERSION_NAME}\x1B[0m\n\n\n\n\n\n"
say -v Carmit "I am not slacking off, my code is compiling."
