#!/bin/bash -e

rm -rf $PWD/artifacts
mkdir -p $PWD/artifacts
curl "https://github.com/react-community/jsc-android-buildscripts/releases/download/v236355.1.1/jsc_dist.zip" -L -o $PWD/artifacts/jsc.zip
unzip $PWD/artifacts/jsc.zip -d $PWD/artifacts
cp -Rf $PWD/artifacts/dist/ ~/.m2/repository/
