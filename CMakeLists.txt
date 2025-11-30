cmake_minimum_required(VERSION 3.10)

project(csad2526KI407StanislavHahin5 LANGUAGES CXX)

# Require C++17
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Add warnings on supported compilers
if(MSVC)
    add_compile_options(/W4 /permissive-)
else()
    add_compile_options(-Wall -Wextra -Wpedantic -Wconversion)
endif()

# Main executable (falls back to root main.cpp)
if(EXISTS ${CMAKE_SOURCE_DIR}/src/main.cpp)
    add_executable(main ${CMAKE_SOURCE_DIR}/src/main.cpp)
elseif(EXISTS ${CMAKE_SOURCE_DIR}/main.cpp)
    add_executable(main ${CMAKE_SOURCE_DIR}/main.cpp)
endif()

# Provide a small library for math operations so tests can link to it
add_library(math_operations STATIC ${CMAKE_SOURCE_DIR}/math_operations.cpp)
target_include_directories(math_operations PUBLIC ${CMAKE_SOURCE_DIR})

install(TARGETS main RUNTIME DESTINATION bin)

# --- GoogleTest + unit tests setup ---
option(ENABLE_TESTS "Enable unit tests (requires GoogleTest)" ON)

if(ENABLE_TESTS)
  include(FetchContent)
  FetchContent_Declare(
    googletest
    URL https://codeload.github.com/google/googletest/tar.gz/refs/tags/release-1.14.0
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
  )
  # For Windows: prevent overriding the parent project's compiler/linker settings
  set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
  
  # Try to fetch, but continue build if it fails
  FetchContent_GetProperties(googletest)
  if(NOT googletest_POPULATED)
    FetchContent_Populate(googletest)
    add_subdirectory(${googletest_SOURCE_DIR} ${googletest_BINARY_DIR} EXCLUDE_FROM_ALL)
  endif()

  enable_testing()

  # Unit test target (only if googletest was available)
  if(TARGET gtest_main)
    add_executable(unit_tests ${CMAKE_SOURCE_DIR}/tests/unit_tests.cpp)
    target_link_libraries(unit_tests PRIVATE gtest_main math_operations)
    target_include_directories(unit_tests PRIVATE ${CMAKE_SOURCE_DIR})

    include(GoogleTest)
    gtest_discover_tests(unit_tests)
  endif()
else()
  enable_testing()
  message(STATUS "Unit tests disabled")
endif()
