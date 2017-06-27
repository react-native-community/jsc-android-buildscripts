# Testing cold start time


## Instructions

To test cold start time you have to:

1. Clone `react-native`, checkout to the latest stable branch, run `yarn add jsc-android` and patch it with [patch to use your copy of JSC](./patches/react-native.patch) and [testing patch](./patches/react-native-testing.patch).
2. Pick an application you want to use for testing and make it [use your react-native copy](http://facebook.github.io/react-native/docs/android-building-from-source.html#2-adding-gradle-dependencies).
3. Build and run application using `react-native run android`.
4. Collect logs `adb logcat | grep JSC_EXEC_TIME > log_file`.
5. Count average run time using `./utils/count_average_time.rb LOG_FILE_1 LOG_FILE_2 ...`.
