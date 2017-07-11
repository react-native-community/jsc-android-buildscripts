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

JSC library built using this project is distributed over npm: [npm/jsc-android](https://www.npmjs.com/package/jsc-android).
The library is packaged as a local Maven repository containing AAR files that include the binaries.
Please refer to the section below in order to learn how your app can consume this format.

## How to use it with my React Native app

Follow steps below in order for your React Native app to use new version of JSC VM on android:

1. Add `jsc-android` to the "dependencies" section in your `package.json`:
```diff
dependencies {
+  "jsc-android": "^216113.0.0-beta.5",
```

then run `npm install` or `yarn` (depending which npm client you use) in order for the new dependency to be installed in `node_modules`

2. Modify `andorid/build.gradle` file to add new local maven repository packaged in the `jsc-android` package to the search path:
```diff
allprojects {
    repositories {
        mavenLocal()
        jcenter()
        maven {
            // All of React Native (JS, Obj-C sources, Android binaries) is installed from npm
            url "$rootDir/../node_modules/react-native/android"
        }
+       maven {
+           // Local Maven repo containing AARs with JSC library built for Android
+           url "$rootDir/../node_modules/jsc-android/android"
+       }
    }
}
```

3. Update your app's `build.gradle` file located in `android/app/build.gradle` to force app builds to use new version of the JSC library as opposed to the version specified in [react-native gradle module as a dependency](https://github.com/facebook/react-native/blob/e8df8d9fd579ff14224cacdb816f9ff07eef978d/ReactAndroid/build.gradle#L289):

```diff
}

+configurations.all {
+    resolutionStrategy {
+        force 'org.webkit:android-jsc:r216113'
+    }
+}

dependencies {
    compile fileTree(dir: "libs", include: ["*.jar"])
```

4. You're done, rebuild your app and enjoy updated version of JSC on android!

## How to use it with React Native

We will be working on updating React Native to use a new version of JSC. Once that gets approved the only thing you will need to do is to update your RN version!

## Testing

As a part of this project we provide a patch to the React Native source code that allows for measuring a React Native application's cold-start. The methodology behind this test is to modify the part of the code that is responsible for loading JS bundles into the JS VM such that we measure and store the execution time, and to modify the process of instantiating the bridge so we can run it multiple times. To learn more about how the perf tests work and how to perform them, refer to [this document](./TESTING.md). Results for the Samsung Galaxy S4 are presented below, cold start has been measured on rather large React Native app with minified bundle of size at around 3M:

|                      | android-jsc (r174650) | new JSC (r216113) |
| -------------------- |----------------------:| -----------------:|
| cold start time      | 2530 ms               | 2150 ms (-15%)    |
| binary size (armv7)  | 1.8 MiB               | 4.4 MiB           |
| binary size (x86)    | 4.4 MiB               | 7.5 MiB           |
| binary size (arm64)  | N/A                   | 6.7 MiB           |
| binary size (x86_64) | N/A                   | 7.4 MiB           |

## ICU data

ICU data are data tables for ICU to provide i18n features such as collation and date/time localization ([read more](http://userguide.icu-project.org/icudata)). Starting with `216113.0.0-beta.6` by default we provide the build with date/time l18n data only (~2.0 MiB per architecture). This allows you to use `Intl.DateTimeFormat` and `Date.toLocaleString`.

### Building ICU with no data

Just uncomment two lines in `icu.sh` responsible for copying `stubdata` lib. This saves ~2.0 MiB per architecture.

### Building ICU also with collation data

Modify `icu-prep.sh` to use `patches/icu-collation.patch` instead of `patches/icu.patch`. This adds additional ~2.2 MiB per architecture.

## Credits

This project has been built in cooperation between [Expo.io](https://expo.io) and [Software Mansion](https://swmansion.com)

[![expo](https://avatars2.githubusercontent.com/u/12504344?v=3&s=100 "Expo.io")](https://expo.io)
[![swm](https://avatars1.githubusercontent.com/u/6952717?v=3&s=100 "Software Mansion")](https://swmansion.com)
