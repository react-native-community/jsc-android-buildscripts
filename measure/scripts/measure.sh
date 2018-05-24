#!/bin/bash -e

PACKAGE_NAME="com.javascriptcore.profiler"

installProfiler() {
  cd android
  ./gradlew clean uninstallRelease installRelease
  cd ..
}

clearLogcat() {
  adb logcat -c
}

waitForLogcatMsg() {
  until adb logcat -d | grep "$1" > /dev/null;
  do
    sleep 1
  done
}

launchProfiler() {
  adb shell am start-activity -W "${PACKAGE_NAME}/.MainActivity" > /dev/null
  sleep 2
}

killProfiler() {
  adb shell am force-stop "${PACKAGE_NAME}"
  adb shell am kill "${PACKAGE_NAME}"
}

clickOnJsTest() {
  adb shell input tap 720 1008 # TODO replace with non-magical values
  waitForLogcatMsg "JavaScriptCoreProfiler:JSProfile:Done"
}

clickOnFlatRenderTest() {
  adb shell input tap 720 1240 # TODO replace with non-magical values
  waitForLogcatMsg "JavaScriptCoreProfiler:RenderFlatResult:"
}

clickOnDeepRenderTest() {
  adb shell input tap 720 1470 # TODO replace with non-magical values
  waitForLogcatMsg "JavaScriptCoreProfiler:RenderDeepResult:"
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

RESULTS=$(adb logcat -d | grep "JavaScriptCoreProfiler")
printf "\n\n\n\nRESULTS:\n\n${RESULTS}\n\n\n\n"
