FROM gengjiawen/android-ndk

RUN apt update && \
    apt install curl git subversion -y && \
    curl -sL https://deb.nodesource.com/setup_8.x | -E bash - && \
    apt install -y nodejs