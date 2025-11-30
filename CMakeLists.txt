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

# Use system/package-managed GoogleTest (vcpkg or other) via find_package
find_package(GTest CONFIG REQUIRED)

enable_testing()

add_executable(unit_tests ${CMAKE_SOURCE_DIR}/tests/unit_tests.cpp)
target_include_directories(unit_tests PRIVATE ${CMAKE_SOURCE_DIR})
target_link_libraries(unit_tests PRIVATE math_operations GTest::gtest GTest::gtest_main)
target_compile_definitions(unit_tests PRIVATE USE_GTEST)

add_test(NAME unit_tests COMMAND unit_tests)
