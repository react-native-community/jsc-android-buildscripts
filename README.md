# JSC build scripts for Android

The aim of this project is to provide maintainable build scripts for the [JavaScriptCore](https://www.webkit.org) JavaScript engine and allow the [React Native](https://github.com/facebook/react-native) project to incorporate up-to-date releases of JSC into the framework on Android.

This project is based on [facebook/android-jsc](https://github.com/facebook/android-jsc) but instead of rewriting JSC's build scripts into BUCK files, it relies on CMake build scripts maintained in a GTK branch of WebKit maintained by the WebKitGTK team (great work btw!). Thanks to that, with just a small amount of work we should be able to build not only current but also future releases of JSC. An obvious benefit for everyone using React Native is that this will allow us to update JSC for React Native on Android much more often than before (note that [facebook/android-jsc](https://github.com/facebook/android-jsc) uses JSC version from Nov 2014), which is especially helpful since React Native on iOS uses the built-in copy of JSC that is updated with each major iOS release (see [this](https://opensource.apple.com/) as a reference).

## Requirements

* Homebrew (https://brew.sh/)
* GNU coreutils `brew install coreutils`
* Node `brew install node`
* Gradle: `brew install gradle`
* Java 8: `brew tap caskroom/versions && brew cask install java8`
* Android SDK: `brew cask install android-sdk`
  * Run `sdkmanager --list` and install all platforms, tools, cmake, ndk (android images are not needed)
  * Set `$ANDROID_HOME` to the correct path (in ~/.bashrc or similar)
  * Set `export ANDROID_NDK=$ANDROID_HOME/ndk-bundle`
  * Set `export PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools/bin`
* Make sure you have Ruby (>2.3), Python (>2.7), Git, SVN, gperf

## Build instructions

1. Clone this repo
2. `npm install`: downloads all needed sources to `./downloaded`
3. `npm run prep`: copies downloaded sources to `./target` and prepare for compilation
4. `npm run start`: builds jsc (this might take some time...) out of prepared sources under `./target` into `./result`

The zipfile containing the android-jsc AAR will be available at `/result`.
The library is packaged as a local Maven repository containing AAR files that include the binaries.
