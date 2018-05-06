#!/bin/bash -e

bitness="x32"
if $npm_package_config_x64 ="true"
then
    bitness="x64"
fi

i18n="en"
if $npm_package_config_i18n = "true"
then
    i18n="i18n"
fi

echo "${npm_package_config_webkitGTK}-${npm_package_config_android_icu}-${bitness}-${i18n}-${npm_package_config_hint}"
