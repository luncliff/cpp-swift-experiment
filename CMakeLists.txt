cmake_minimum_required(VERSION 3.17)
project(sample LANGUAGES CXX VERSION 1.0.0)
if(APPLE)
    set(CMAKE_Swift_LANGUAGE_VERSION 5.4)
    enable_language(Swift)
endif()

if(CMAKE_TOOLCHAIN_FILE MATCHES vcpkg.cmake)
    message(STATUS "Using vcpkg: ${VCPKG_TARGET_TRIPLET}")
endif()
find_package(Protobuf 3.10 CONFIG REQUIRED)

find_program(protoc_path NAMES protoc REQUIRED)
message(STATUS "Using protoc: ${protoc_path}")
add_custom_target(codegen
    COMMAND ${protoc_path} --version
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
)

add_custom_target(codegen_cpp
    COMMAND ${protoc_path} sample.proto --cpp_out=${CMAKE_CURRENT_BINARY_DIR}
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    BYPRODUCTS  sample.pb.h
                sample.pb.cc
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
        COMMAND ${protoc_path} sample.proto --swift_out=${PROJECT_SOURCE_DIR}/Sources
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
        BYPRODUCTS  sample.pb.swift
    )
    add_dependencies(codegen codegen_swift)
endif()

add_library(sample
    sample.pb.h
    sample.pb.cc
)
add_dependencies(sample codegen_cpp)

list(APPEND headers ${CMAKE_CURRENT_BINARY_DIR}/sample.pb.h)

set_target_properties(sample
PROPERTIES
    CXX_STANDARD 17
    PUBLIC_HEADER "${headers}"
    XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY  "1,2"
)

target_link_libraries(sample
PUBLIC
    protobuf::libprotobuf-lite # protobuf::libprotobuf
)

if(APPLE)
    target_link_libraries(sample
    PRIVATE
        "-framework Metal"
    )
endif()

include(GNUInstallDirs)

install(FILES sample.proto
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)
install(TARGETS sample
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)
