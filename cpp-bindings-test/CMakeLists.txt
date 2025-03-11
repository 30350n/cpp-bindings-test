cmake_minimum_required(VERSION 3.16)
project(cpp-bindings-test)
set(CMAKE_CXX_VERSION 20)
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

add_library(cpp-bindings-test SHARED
    src/main.cpp
)

install(TARGETS cpp-bindings-test DESTINATION lib)

option(TESTING "Enable tests." ON)
if (TESTING)
    enable_testing()
    add_executable(cpp-bindings-test_test
        test/test.cpp
    )
    target_link_libraries(cpp-bindings-test_test PRIVATE cpp-bindings-test)
    add_test(NAME cpp-bindings-test_test COMMAND cpp-bindings-test_test)
endif()
