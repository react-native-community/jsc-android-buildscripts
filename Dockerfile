FROM bitriseio/android-ndk

ENV ANDROID_NDK ${ANDROID_NDK_HOME}

## enhancements
RUN sdkmanager "cmake;3.6.3155560"

# subversion
RUN apt-get install subversion gperf -y
