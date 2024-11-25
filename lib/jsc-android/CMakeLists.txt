cmake_minimum_required(VERSION 3.13)
set(CMAKE_VERBOSE_MAKEFILE on)
project(jsc-android)

add_library(jsclib SHARED IMPORTED GLOBAL)

set_target_properties(jsclib
  PROPERTIES
  IMPORTED_LOCATION
  "${PREBUILT_LIBS_DIR}/${ANDROID_ABI}/libjsc.so")

add_library(jsc SHARED empty.cpp)
