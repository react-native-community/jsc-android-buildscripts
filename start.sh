#!/bin/bash -e

which xcpretty >/dev/null 2>&1 && xc=xcpretty || xc=cat

./icu-prep.sh | xcpretty
./jsc-prep.sh | xcpretty
./all.sh | xcpretty
cd lib
./gradlew clean installArchives
cd ..
mkdir output
mv lib/android output/android
say -v Carmit \"I'm not slacking off, my code's compiling\"
