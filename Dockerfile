FROM gengjiawen/android-ndk

RUN apt-get install curl git subversion -y && \
    curl -sL https://deb.nodesource.com/setup_8.x | -E bash - && \
    apt-get install -y nodejs