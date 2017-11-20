FROM bitriseio/android-ndk:v2017_11_18-09_24-b779

ENV ANDROID_NDK ${ANDROID_NDK_HOME}

## enhancements
RUN sdkmanager "cmake;3.6.4111459"

# subversion
RUN apt-get install subversion gperf -y
