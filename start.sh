#!/bin/bash -e

./icu-prep.sh
./jsc-prep.sh
./all.sh
cd lib
./gradlew clean installArchives
cd ..
mkdir output
mv lib/android output/android
say -v Carmit \"I'm not slacking off, my code's compiling\"
