#!/bin/bash -e

bitness="x32"
i18n=""

if ${npm_package_config_x64}
then
	bitness="x64"
fi

if ${npm_package_config_i18n}
then
	i18n="-i18n"
fi

export VERSION_NAME="${npm_package_config_webkitGTK}-${npm_package_config_android_icu}-${npm_package_config_hint}-${bitness}${i18n}"
