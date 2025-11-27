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
include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/refs/tags/release-1.14.0.tar.gz
)
# For Windows: prevent overriding the parent project's compiler/linker settings
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

enable_testing()

# Unit test target
add_executable(unit_tests ${CMAKE_SOURCE_DIR}/tests/unit_tests.cpp)
target_link_libraries(unit_tests PRIVATE gtest_main math_operations)
target_include_directories(unit_tests PRIVATE ${CMAKE_SOURCE_DIR})

include(GoogleTest)
gtest_discover_tests(unit_tests)
