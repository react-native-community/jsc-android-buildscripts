#!/bin/bash -e

# Install the profiler
cd android
./gradlew clean uninstallRelease
./gradlew installRelease
cd ..

# Clear the logcat
adb logcat -c

# Launch and wait for completion
# adb shell am start-activity -W "com.javascriptcore.profiler/.MainActivity"

cd robot
./gradlew connectedAndroidTest
cd ..

sleep 2

adb logcat -d | grep "JavaScriptCoreProfiler"
