FROM gengjiawen/android-ndk

RUN apt update && \
    apt install curl git subversion ruby gperf -y && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt install -y nodejs