cmake_minimum_required(VERSION 3.16)
project(cpp-bindings-test)
set(CMAKE_CXX_VERSION 20)

add_library(cpp-bindings-test SHARED
    src/main.cpp
)

install(TARGETS cpp-bindings-test DESTINATION lib)

option(TESTING "Enable tests." ON)
if (TESTING)
    enable_testing()
    add_executable(cpp-bindings-test-test
        test/test.cpp
    )
    target_link_libraries(cpp-bindings-test-test PRIVATE cpp-bindings-test)
    add_test(NAME cpp-bindings-test-test COMMAND cpp-bindings-test-test)
endif()
