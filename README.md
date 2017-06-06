# JSC build scripts for Android

The aim of this project is to provide a maintainable build scripts for [JavaScriptCore](https://www.webkit.org) javascript engine that would allow the [React Native](https://github.com/facebook/react-native) community to incorporate up to date releases of JSC into the framework on Android.

This project is based on [facebook/android-jsc](https://github.com/facebook/android-jsc) but instead of rewriting JSC builds scripts in BUCK it relies on cmake build scripts maintained in GTK branch of WebKit maintained by the WebkitGTK team (great work btw!). Thanks to that with just a small amount of work we should be able to build not only current but also future releases of JSC. An obvious benefit for everyone using react native is that this will allow to update JSC version on android version much more often than before (note that [facebook/android-jsc](https://github.com/facebook/android-jsc) uses JSC version from Nov 2014), especially that react native on iOS uses builtin instance of JSC library which gets regular updates with every version of iOS (see [this](https://opensource.apple.com/) as a reference).



## Requirements

You can try the provided Docker image.
To use it prefix each command with `docker run -vLOCAL_WORKDIR_PATH:/bitrise/src --rm swmansion/jsc-android-buildscripts`.

## Build instructions

1. `git clone https://github.com/SoftwareMansion/jsc-android-buildscripts.git .`
2. `./fetch_sources.sh`
3. `./icu-prep.sh`
4. `./jsc-prep.sh`
5. `./all.sh`
6. `./gradlew installArchives` (add `-w /bitrise/src/lib` to `docker run` args)

The maven repo containing android-jsc aar will be available at `LOCAL_WORKDIR_PATH/lib/android`.

## Distribution

## How to use it with React Native

## Testing

## Credits

This project has been built in cooperation between [Expo.io](https://expo.io/) and [Software Mansion](https://swmansion.com)
