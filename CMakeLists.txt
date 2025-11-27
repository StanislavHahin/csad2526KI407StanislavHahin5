cmake_minimum_required(VERSION 3.10)

project(csad2526_ki407_stanislav_hahin LANGUAGES CXX)

# Require C++17
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Add warnings on supported compilers
if(MSVC)
    add_compile_options(/W4 /permissive-)
else()
    add_compile_options(-Wall -Wextra -Wpedantic -Wconversion)
endif()

# Source files
set(SRC_MAIN ${CMAKE_SOURCE_DIR}/main.cpp)
set(SRC_MATH ${CMAKE_SOURCE_DIR}/math_operations.cpp)

if(EXISTS ${SRC_MAIN})
    add_executable(main ${SRC_MAIN})
endif()

add_library(math_operations STATIC ${SRC_MATH})
target_include_directories(math_operations PUBLIC ${CMAKE_SOURCE_DIR})

if(TARGET main)
    target_link_libraries(main PRIVATE math_operations)
endif()

install(TARGETS main RUNTIME DESTINATION bin)

include(FetchContent)

option(FORCE_FETCH_GTEST "Force fetching GoogleTest via FetchContent" OFF)

# Try to obtain GoogleTest for CI (on GITHUB_ACTIONS) or when vendored copy exists.
set(GTEST_AVAILABLE OFF)
if(EXISTS ${CMAKE_SOURCE_DIR}/googletest-main/CMakeLists.txt)
        message(STATUS "Using vendored googletest from ${CMAKE_SOURCE_DIR}/googletest-main")
        add_subdirectory(${CMAKE_SOURCE_DIR}/googletest-main ${CMAKE_BINARY_DIR}/googletest)
        set(GTEST_AVAILABLE ON)
elseif(DEFINED ENV{GITHUB_ACTIONS} OR DEFINED ENV{CI} OR FORCE_FETCH_GTEST)
        message(STATUS "Attempting to FetchContent googletest (CI or forced)")
        FetchContent_Declare(
            googletest
            URL https://github.com/google/googletest/archive/refs/tags/release-1.14.0.tar.gz
        )
        set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
        FetchContent_MakeAvailable(googletest)
        if(TARGET gtest_main)
            set(GTEST_AVAILABLE ON)
        endif()
else()
        find_package(GTest QUIET)
        if(GTest_FOUND)
            set(GTEST_AVAILABLE ON)
        endif()
endif()

enable_testing()

# Unit test target: single source supports both GoogleTest and lightweight fallback
add_executable(unit_tests ${CMAKE_SOURCE_DIR}/tests/unit_tests.cpp)
target_include_directories(unit_tests PRIVATE ${CMAKE_SOURCE_DIR})
target_link_libraries(unit_tests PRIVATE math_operations)

if(GTEST_AVAILABLE)
    target_compile_definitions(unit_tests PRIVATE USE_GTEST)
    target_link_libraries(unit_tests PRIVATE gtest_main)
    message(STATUS "Unit tests will be built with GoogleTest")
else()
    message(STATUS "GoogleTest not available; building lightweight test runner")
endif()

add_test(NAME unit_tests COMMAND unit_tests)
