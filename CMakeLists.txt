# see https://developer.apple.com/library/archive/documentation/DeveloperTools/Reference/XcodeBuildSettingRef/1-Build_Setting_Reference/build_setting_ref.html
cmake_minimum_required(VERSION 3.31)
project(cpp_swift_bridges LANGUAGES CXX VERSION 1.3)

include(GNUInstallDirs)
set(CMAKE_CXX_STANDARD 20)

message(STATUS "Using system: ${CMAKE_SYSTEM_VERSION}")
message(STATUS "Using compiler: ${CMAKE_CXX_COMPILER_ID}")
if(APPLE)
    find_program(CMAKE_Swift_COMPILER NAMES swiftc REQUIRED)
    enable_language(Swift)
    message(STATUS "Using swiftc: ${CMAKE_Swift_COMPILER}")

    set(SWIFT_VERSION "5.0" CACHE STRING "Swift language version. 5.0 or 6.0")
    if(CMAKE_GENERATOR MATCHES "Xcode")
        set(CMAKE_XCODE_ATTRIBUTE_SWIFT_VERSION "${SWIFT_VERSION}")
    elseif(CMAKE_GENERATOR MATCHES "Ninja")
        # ...
    endif()
endif()
if(ENABLE_COVERAGE)
    add_compile_options(-Wextra -ftest-coverage -fprofile-arcs)
    add_link_options(-ftest-coverage -fprofile-arcs)
endif()

find_library(BORINGSSL_LIBPATH NAMES boringssl REQUIRED)
message(STATUS "Using BoringSSL: ${BORINGSSL_LIBPATH}")

find_package(Protobuf REQUIRED)
if(NOT DEFINED Protobuf_PROTOC_EXECUTABLE)
    find_program(Protobuf_PROTOC_EXECUTABLE NAMES protoc REQUIRED)
endif()
message(STATUS "Using protoc: ${Protobuf_PROTOC_EXECUTABLE}")

find_path(MetalCpp_INCLUDE_DIR
    NAMES "Metal/Metal.hpp"
    PATHS ${PROJECT_SOURCE_DIR}/externals/metal-cpp
    REQUIRED
)
message(STATUS "Using Metal.hpp: ${MetalCpp_INCLUDE_DIR}")

list(APPEND ifcs
    src/Baguette.h
)

# Must be SHARED to keep Swift types' namespace...
# It should be `BaguetteBridge` instead of `baguette_test`
add_library(BaguetteBridge SHARED ${ifcs} ${bridges})

# see https://cmake.org/cmake/help/latest/prop_tgt/FRAMEWORK.html
set_target_properties(BaguetteBridge
PROPERTIES
    PUBLIC_HEADER "${ifcs};${bridges}"
    FRAMEWORK true
    FRAMEWORK_VERSION B
    VERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    XCODE_ATTRIBUTE_ENABLE_TESTABILITY "YES" # for XCTest
    # LINKER_LANGUAGE Swift
)

if(DEFINED bridges) # For customized bridging headers
    set_target_properties(BaguetteBridge
    PROPERTIES
        XCODE_ATTRIBUTE_SWIFT_OBJC_BRIDGING_HEADER "${bridges}"
    )
endif()

target_include_directories(BaguetteBridge
PUBLIC
    ${MetalCpp_INCLUDE_DIR}
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src>
)

target_link_libraries(BaguetteBridge
PUBLIC
    "-framework Foundation" "-framework Metal"
    ${BORINGSSL_LIBPATH}
)

list(APPEND SWIFT_SRCS
    platform-apple/AsyncRoutines.swift
    platform-apple/BaguetteBridge.swift
    platform-apple/CryptoRoutines.swift
    platform-apple/DecoderRoutines.swift
    platform-apple/HostInfo.swift
)
set_source_files_properties(${SWIFT_SRCS}
PROPERTIES
    LANGUAGE Swift
    COMPILE_OPTIONS "SHELL:-swift-version ${SWIFT_VERSION}"
)

target_sources(BaguetteBridge
PRIVATE
    src/bridge_apple.cpp
    ${SWIFT_SRCS}
    src/swift_crypto.cpp
    src/swift_crypto.hpp
    src/swift_decoder.cpp
    src/swift_decoder.hpp
    src/swift_hostinfo.hpp
    src/swift_hostinfo.cpp
)

install(TARGETS BaguetteBridge FRAMEWORK DESTINATION ${CMAKE_INSTALL_LIBDIR})

if(NOT BUILD_TESTING)
    return()
endif()
enable_testing()

add_executable(baguette_test
    test/baguette_test.cpp
)

target_compile_features(baguette_test
PRIVATE
    cxx_std_20
)

target_include_directories(baguette_test
PRIVATE
    src test
)

target_link_libraries(baguette_test
PRIVATE
    "-framework Foundation"
    BaguetteBridge
)

install(TARGETS baguette_test RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})

add_test(NAME run_baguette_test COMMAND baguette_test WORKING_DIRECTORY ${PROJECT_BINARY_DIR})
