# JSC build scripts for Android

The aim of this project is to provide maintainable build scripts for the [JavaScriptCore](https://www.webkit.org) JavaScript engine and allow the [React Native](https://github.com/facebook/react-native) community to incorporate up-to-date releases of JSC into the framework on Android.

This project is based on [facebook/android-jsc](https://github.com/facebook/android-jsc) but instead of rewriting JSC's build scripts into BUCK files, it relies on CMake build scripts maintained in a GTK branch of WebKit maintained by the WebKitGTK team (great work btw!). Thanks to that, with just a small amount of work we should be able to build not only current but also future releases of JSC. An obvious benefit for everyone using React Native is that this will allow us to update JSC for React Native on Android much more often than before (note that [facebook/android-jsc](https://github.com/facebook/android-jsc) uses JSC version from Nov 2014), which is especially helpful since React Native on iOS uses the built-in copy of JSC that is updated with each major iOS release (see [this](https://opensource.apple.com/) as a reference).

## Requirements

There is a huge list of requirements that need to be installed on your system in order to be able to cross-compile JSC for Android. To simplify the process of setting up the environment we provide a Docker image that comes with everything you will need. If you decide to use our Docker image, the only thing you need to do is to prefix each command with this:
```sh
docker run -v `pwd`:/bitrise/src --rm swmansion/jsc-android-buildscripts
```

##### Example:

```sh
docker run -v `pwd`:/bitrise/src --rm swmansion/jsc-android-buildscripts ./fetch_sources.sh
```

#### Don't want to use Docker

As mentioned the list of dependencies is huge, we tried to list everything that is needed below:
 - Android SDK & NDK
 - Ruby (2.3), Python (2.7), Node (7.x), Git, SVN, gperf
 - CMake installed via Android SDK manager

## Build instructions

> **IMPORTANT:** Remember to prefix each command with the appropriate Docker command given above when using our Docker image

1. `git clone https://github.com/SoftwareMansion/jsc-android-buildscripts.git .`
2. `./fetch_sources.sh`
3. `./icu-prep.sh`
4. `./jsc-prep.sh`
5. `./all.sh`
6. `./gradlew installArchives` (add `-w /bitrise/src/lib` to `docker run` args)

The Maven repo containing the android-jsc AAR will be available at `./lib/android`.

## Distribution

(TODO)

## How to use it with React Native

We will be working on updating React Native to use a new version of JSC. Once that gets approved the only thing you will need to do is to update your RN version! Until then you can fork React Native and patch it with [this patch](./patches/react-native.patch).

## Testing

As a part of this project we provide a patch to the React Native source code that allows for measuring a React Native application's cold-start time. The methodology behind this test is to modify the part of the code that is responsible for loading JS bundles into the JS VM such that we measure and store the execution time, and to modify the process of instantiating the bridge so we can run it multiple times. To learn more about how the perf tests work and how to perform them, refer to [this document](./TESTING.md). Results for the Samsung Galaxy S4 are presented below:

|                      | android-jsc (r174650) | new JSC (r216995) |
| -------------------- |----------------------:| -----------------:|
| cold start time      | 427 ms                | 443 ms            |
| binary size (armv7)  | 1.8 MiB               | 5.7 MiB           |
| binary size (x86)    | 4.4 MiB               | 10 MiB            |
| binary size (arm64)  | N/A                   | 11 MiB            |
| binary size (x86_64) | N/A                   | 13 MiB            |

## Credits

This project has been built in cooperation between [Expo.io](https://expo.io) and [Software Mansion](https://swmansion.com)

[![expo](https://avatars2.githubusercontent.com/u/12504344?v=3&s=100 "Expo.io")](https://expo.io)
[![swm](https://avatars1.githubusercontent.com/u/6952717?v=3&s=100 "Software Mansion")](https://swmansion.com)
