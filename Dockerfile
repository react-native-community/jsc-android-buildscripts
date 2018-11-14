# The below version corresponds to NDK r17b
FROM quay.io/bitriseio/android-ndk:v2018_09_08-07_56-b1165

# Upgrade npm
RUN npm install -g npm

# JSC buildscripts use ANDROID_NDK env variable
ENV ANDROID_NDK ${ANDROID_NDK_HOME}

# Install cmake
RUN sdkmanager "cmake;3.6.4111459"

# Install subversion
RUN apt-get install subversion gperf -y

