## How to compile

### Requirements
* gradle: `brew install gradle`
* nvm: `brew install nvm`
* java8: `brew tap caskroom/versions && brew cask install java8`
* android sdk: `brew cask install android-sdk`
  * `sdkmanager --list` and install all platforms, tools, cmake, ndk (images not needed)
  * set `$ANDROID_HOME`
  * set `export ANDROID_NDK=$ANDROID_HOME/ndk-bundle`
  * set `export PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools/bin`
* make sure Ruby (2.3), Python (2.7), node (7), Git, SVN, gperf
* gnu core utils: `brew install coreutils`
