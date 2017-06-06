# JSC Android buildscripts

## How to compile?

1. `docker build . -tjscBuild`
2. `clone the repo in the container`
2. `./fetch_sources.sh`
3. `./icu-prep.sh`
4. `./jsc-prep.sh`
5. `./all.sh`
6. `cd lib && ./gradlew installArchives`