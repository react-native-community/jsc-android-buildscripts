#!/bin/bash -e

VERSION_NAME="${npm_package_config_webkitGTK}-${npm_package_config_android_icu}-${npm_package_config_name}"
sed -i.bak "s/VERSION_NAME=.*/VERSION_NAME=${VERSION_NAME}/" lib/lib/gradle.properties lib/libIntl/gradle.properties
rm lib/lib/gradle.properties.bak lib/libIntl/gradle.properties.bak
