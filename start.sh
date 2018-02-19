#!/bin/bash -e

source ./calc-version.sh

./all.sh
cd lib
./gradlew clean lib:installArchives
cd ..

zip "$VERSION_NAME" "lib/android/**/*"

printf "\n\n\n\n\n\t\t\tCompiled Version: ${VERSION_NAME}\n\n\n\n\n\n"
say -v Carmit \"I'm not slacking off, my code's compiling\"
say "$VERSION_NAME"
