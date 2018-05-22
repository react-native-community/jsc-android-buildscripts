#!/bin/bash -e

PACKAGE_NAME="com.javascriptcore.profiler"

installProfiler() {
  cd android
  ./gradlew clean uninstallRelease
  ./gradlew installRelease
  cd ..
}

clearLogcat() {
  adb logcat -c
}

launchProfiler() {
  adb shell am start-activity -W "${PACKAGE_NAME}/.MainActivity"
  sleep 2
}

killProfiler() {
  adb shell am force-stop "${PACKAGE_NAME}"
  adb shell am kill "${PACKAGE_NAME}"
}

clickOnJsTest() {
  adb shell input tap 720 1008
  sleep 2
}

clickOnFlatRenderTest() {
  adb shell input tap 720 1240
  sleep 2
}

clickOnDeepRenderTest() {
  adb shell input tap 720 1470
  sleep 2
}

installProfiler
clearLogcat

launchProfiler
clickOnJsTest
killProfiler

launchProfiler
clickOnFlatRenderTest
killProfiler

launchProfiler
clickOnDeepRenderTest
killProfiler

adb logcat -d | grep "JavaScriptCoreProfiler"
