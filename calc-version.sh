#!/bin/bash -e

bitness="x32"

if ${npm_package_config_x64}
then
	bitness="x64"
fi

export VERSION_NAME="${npm_package_config_webkitGTK}-${npm_package_config_android_icu}-${npm_package_config_hint}-${bitness}"
