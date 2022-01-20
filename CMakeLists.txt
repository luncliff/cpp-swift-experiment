cmake_minimum_required(VERSION 3.21)
project(sample LANGUAGES CXX VERSION 1.0.0)
if(APPLE)
    set(CMAKE_Swift_LANGUAGE_VERSION 5.3)
    enable_language(Swift)
endif()

if(CMAKE_TOOLCHAIN_FILE MATCHES vcpkg.cmake)
    message(STATUS "Using vcpkg: ${VCPKG_TARGET_TRIPLET}")
endif()

# https://cmake.org/cmake/help/v3.21/module/FindProtobuf.html
find_package(Protobuf 3.10 CONFIG REQUIRED)
if(NOT DEFINED Protobuf_PROTOC_EXECUTABLE)
    find_program(protoc_path NAMES protoc REQUIRED)
else()
    set(protoc_path ${Protobuf_PROTOC_EXECUTABLE})
endif()

message(STATUS "Using protoc: ${protoc_path}")
add_custom_target(codegen
    COMMAND ${protoc_path} --version
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
)

add_custom_target(codegen_cpp
    COMMAND ${protoc_path} sample.proto --cpp_out=${PROJECT_SOURCE_DIR}/Sources/scone_native
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    BYPRODUCTS  ${PROJECT_SOURCE_DIR}/Sources/scone_native/sample.pb.h
                ${PROJECT_SOURCE_DIR}/Sources/scone_native/sample.pb.cc
)
add_dependencies(codegen codegen_cpp)

find_program(protoc_swift_plugin_path NAMES protoc-gen-swift)
if(NOT protoc_swift_plugin_path)
    # see https://github.com/apple/swift-protobuf
    # see https://formulae.brew.sh/formula/swift-protobuf
    message(WARNING "Program 'protoc-gen-swift' is not found")
else()
    message(STATUS "Using protoc-gen-swift: ${protoc_swift_plugin_path}")
    add_custom_target(codegen_swift
        COMMAND ${protoc_path} sample.proto --swift_out=${PROJECT_SOURCE_DIR}/Sources/scone
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
        BYPRODUCTS  sample.pb.swift
    )
    add_dependencies(codegen codegen_swift)
endif()
