FROM gengjiawen/android-ndk

RUN apt-get install subversion -y && \
    curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash - && \
    apt-get install -y nodejs