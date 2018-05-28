#!/bin/bash -e

svn info --show-item last-changed-revision "https://svn.webkit.org/repository/webkit/releases/WebKitGTK/webkit-${npm_package_config_webkitGTK}/"
