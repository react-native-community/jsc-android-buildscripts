# JSC build scripts for Android

The aim of this project is to provide a maintainable build scripts for [JavaScriptCore](https://www.webkit.org) javascript engine that would allow the [React Native](https://github.com/facebook/react-native) community to incorporate up to date releases of JSC into the framework on Android.

This project is based on [facebook/android-jsc](https://github.com/facebook/android-jsc) but instead of rewriting JSC builds scripts in BUCK it relies on cmake build scripts maintained in GTK branch of WebKit maintained by the WebkitGTK team (great work btw!). Thanks to that with just a small amount of work we should be able to build not only current but also future releases of JSC. An obvious benefit for everyone using react native is that this will allow to update JSC version on android version much more often than before (note that [facebook/android-jsc](https://github.com/facebook/android-jsc) uses JSC version from Nov 2014), especially that react native on iOS uses builtin instance of JSC library which gets regular updates with every version of iOS (see [this](https://opensource.apple.com/) as a reference).



## Requirements


There is a huge list of requirements that needs to be installed on your system in order to be able to cross-compile JSC for android. To simplify the process of setting up the environment we provide a docker image that comes with everything you will need. If you decide to use our docker the only thing you need to do is to prefix each command with this:
```sh
docker run -vLOCAL_WORKDIR_PATH:/bitrise/src --rm swmansion/jsc-android-buildscripts
```

##### Example:

```sh
docker run -vLOCAL_WORKDIR_PATH:/bitrise/src --rm swmansion/jsc-android-buildscripts ./fetch_sources.sh
```

#### Don't want to use docker

As mentioned the list of dependencies is huge, we tried to list everything what's needed below:
 - Android SDK & NDK
 - ruby (2.3), python (2.7), node (7.x), git, svn, gperf
 - cmake installed via Android SDK manager

## Build instructions

> **IMPORTANT:** Remember to prefix each command with an appropriate docker instruction given above when using our docker image

1. `git clone https://github.com/SoftwareMansion/jsc-android-buildscripts.git .`
2. `./fetch_sources.sh`
3. `./icu-prep.sh`
4. `./jsc-prep.sh`
5. `./all.sh`
6. `./gradlew installArchives` (add `-w /bitrise/src/lib` to `docker run` args)

The maven repo containing android-jsc aar will be available at `LOCAL_WORKDIR_PATH/lib/android`.

## Distribution

(TODO)

## How to use it with React Native

We will be working on getting react-native core updated in order to use new version of JSC. Once that gets approved the only thing you will need to do is to update your RN version! Until then you can fork react-native and patch it with [this patch](./patches/react-native.patch).

## Testing

As a part of this project we provide a patch to react-native source code that allows for measuring react native application cold-start time. The methodology behind this test is to modify the part of the code that is responsible for loading JS bundle into the JS VM such that we measure and store the execution time, then we modify the process of instantiating the bridge in a way that allows for running in multiple times. To learn more about how the perf tests work and how to perform them refer to [this document](./TESTING.md). Results for Samsung Galaxy S4 are presented below:

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
