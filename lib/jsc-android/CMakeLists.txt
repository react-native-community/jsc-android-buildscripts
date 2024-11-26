cmake_minimum_required(VERSION 3.13)
set(CMAKE_VERBOSE_MAKEFILE on)
project(jsc-android)

add_library(jsc SHARED empty.cpp)

set(OUTPUT_SRC "${PREBUILT_LIBS_DIR}/${ANDROID_ABI}/libjsc.so")
set(OUTPUT_DST "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/libjsc.so")

add_custom_command(
  TARGET jsc POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
          ${OUTPUT_SRC}
          ${OUTPUT_DST}
  COMMENT "Overwriting ${OUTPUT_SRC} to ${OUTPUT_DST}"
)
