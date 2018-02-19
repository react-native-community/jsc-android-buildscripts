#!/bin/bash -e

source ./calc-version.sh

./all.sh
cd lib
./gradlew clean lib:installArchives

cd android
zip -r "../../result/$VERSION_NAME.zip" "."

printf "\n\n\n\n\n\t\t\tCompiled Version: ${VERSION_NAME}\n\n\n\n\n\n"
say -v Carmit "I am not slacking off, my code's compiling"
