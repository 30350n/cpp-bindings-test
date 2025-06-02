cmake_minimum_required(VERSION 3.16)

project(cpp-bindings-test
    DESCRIPTION "cpp-bindings-test description"
    HOMEPAGE_URL https://github.com/30350n/cpp-bindings-test
    VERSION 0.1.0
)

set(CMAKE_CXX_VERSION 20)
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

add_library(cpp-bindings-test SHARED
    src/main.cpp
)

option(COMPAT_HEADERS "Headers for compatibility with old libc versions" "")
if (COMPAT_HEADERS)
    foreach (header IN LISTS COMPAT_HEADERS)
        target_include_directories(cpp-bindings-test PRIVATE -include ${header})
    endforeach()
endif()

option(COMPAT_LIBS "Library paths for compatibility with old libc versions" "")
if (COMPAT_LIBS)
target_link_options(cpp-bindings-test PRIVATE -static-libgcc -static-libstdc++)
    foreach (lib IN LISTS COMPAT_LIBS)
        target_link_options(cpp-bindings-test PRIVATE -L${lib})
    endforeach()
endif()

set_target_properties(cpp-bindings-test PROPERTIES PUBLIC_HEADER
    include/cpp-bindings-test.h
)
configure_file(cpp-bindings-test.pc.in cpp-bindings-test.pc @ONLY)

install(TARGETS cpp-bindings-test
    LIBRARY DESTINATION lib
    PUBLIC_HEADER DESTINATION include
)
install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/cpp-bindings-test.pc DESTINATION lib/pkgconfig
)

option(TESTING "Enable tests." ON)
if (TESTING)
    enable_testing()
    add_executable(cpp-bindings-test_test
        test/test.cpp
    )
    target_link_libraries(cpp-bindings-test_test PRIVATE cpp-bindings-test)
    add_test(NAME cpp-bindings-test_test COMMAND cpp-bindings-test_test)
endif()
