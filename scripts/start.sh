#!/bin/bash -ex

ROOTDIR=$PWD
VERSION_NAME=$($ROOTDIR/scripts/getVersion.sh)

$ROOTDIR/scripts/compile/all.sh

cd $ROOTDIR/lib
./gradlew clean installArchives

cd $ROOTDIR/lib/android
zip -r "../../result/$VERSION_NAME.zip" "."

cd $ROOTDIR
git add -A
git commit -m "compiled $VERSION_NAME"

printf "\n\n\n\n\n\t\t\tCompiled Version: ${VERSION_NAME}\n\n\n\n\n\n"
say -v Carmit "I am not slacking off, my code's compiling"
