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

# Define executable
add_executable(main src/main.cpp)

# If main.cpp is in the repo root, allow that path as fallback
if(NOT TARGET main)
    add_executable(main ${CMAKE_SOURCE_DIR}/main.cpp)
endif()

install(TARGETS main RUNTIME DESTINATION bin)
