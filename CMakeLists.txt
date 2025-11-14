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

# --- Enable testing ---
enable_testing()

# --- GoogleTest + unit tests setup ---
option(ENABLE_TESTS "Enable unit tests (requires GoogleTest)" ON)

if(ENABLE_TESTS)
  # Prefer a local copy of GoogleTest if it exists (common download locations)
  set(GTEST_LOCAL_DIRS
    ${CMAKE_SOURCE_DIR}/googletest
    ${CMAKE_SOURCE_DIR}/googletest-main
    ${CMAKE_SOURCE_DIR}/third_party/googletest
    ${CMAKE_SOURCE_DIR}/external/googletest
  )

  set(GTEST_LOCAL_FOUND OFF)
  foreach(_gdir ${GTEST_LOCAL_DIRS})
    if(EXISTS ${_gdir}/CMakeLists.txt)
      message(STATUS "Using local GoogleTest at: ${_gdir}")
      add_subdirectory(${_gdir} ${CMAKE_BINARY_DIR}/googletest EXCLUDE_FROM_ALL)
      set(GTEST_LOCAL_FOUND ON)
      break()
    endif()
  endforeach()

  if(NOT GTEST_LOCAL_FOUND)
    # Try to find an installed GoogleTest package first
    find_package(GTest CONFIG QUIET)
    if(NOT GTest_FOUND)
      find_package(GTest QUIET)
    endif()
  endif()

  # If we don't already have GoogleTest (local add_subdirectory or package), try FetchContent
  if(NOT (TARGET gtest_main OR TARGET GTest::gtest_main OR TARGET GTest::gtest))
    include(FetchContent)
    message(STATUS "GoogleTest not found locally or via find_package; fetching via FetchContent (git)")
    # Use the git repository (avoids codeload tarball 404s on some runners)
    FetchContent_Declare(
      googletest
      GIT_REPOSITORY https://github.com/google/googletest.git
      GIT_TAG release-1.14.0
    )
    # Modern API: make available
    FetchContent_MakeAvailable(googletest)
  endif()

  # If we have targets (either from local add_subdirectory, package, or FetchContent), add unit tests
  if(TARGET gtest_main OR TARGET GTest::gtest_main OR TARGET GTest::gtest)
    message(STATUS "GoogleTest available - adding unit_tests target")
    add_executable(unit_tests ${CMAKE_SOURCE_DIR}/tests/unit_tests.cpp)

    if(TARGET gtest_main)
      target_link_libraries(unit_tests PRIVATE gtest_main math_operations)
    elseif(TARGET GTest::gtest_main)
      target_link_libraries(unit_tests PRIVATE GTest::gtest_main math_operations)
    else()
      target_link_libraries(unit_tests PRIVATE GTest::gtest math_operations)
    endif()

    target_include_directories(unit_tests PRIVATE ${CMAKE_SOURCE_DIR})

    # Register the test so ctest will run it
    add_test(NAME unit_tests COMMAND unit_tests)
    message(STATUS "Unit tests registered with CTest")
  else()
    message(WARNING "GoogleTest not available - unit tests will not be built")
  endif()
else()
  message(STATUS "Unit tests disabled by ENABLE_TESTS=OFF")
endif()
