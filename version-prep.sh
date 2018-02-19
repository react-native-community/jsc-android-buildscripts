#!/bin/bash -e

source ./calc-version.sh

sed -i.bak "s/VERSION_NAME=.*/VERSION_NAME=${VERSION_NAME}/" lib/lib/gradle.properties lib/libIntl/gradle.properties
rm lib/lib/gradle.properties.bak lib/libIntl/gradle.properties.bak
