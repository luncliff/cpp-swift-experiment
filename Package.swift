// swift-tools-version: 5.9


import PackageDescription

//
// Reference
// * https://swift.org/documentation/cxx-interop/
//
let package = Package(
    name: "Baguette",
    products: [
        .library(
            name: "BaguetteBridge",
            targets: ["BaguetteBridge"]),
        .library(
            name: "Baguette",
            type: .static,
            targets: ["Baguette"])
    ],
    targets: [
        .target(
            name: "Baguette",
            path: "src",
            sources: [
                "Baguette.h",
                "bridge_apple.cpp",
                "swift_crypto.hpp",
                "swift_crypto.cpp",
                "swift_decoder.hpp",
                "swift_decoder.cpp",
                "swift_hostinfo.hpp",
                "swift_hostinfo.cpp"
            ],
            publicHeadersPath: ".",
            cxxSettings: [
                .headerSearchPath("../externals/metal-cpp"),
                .define("_DEBUG", to: "1", .when(configuration: .debug))
            ],
            linkerSettings: [
                // .unsafeFlags(["-fprofile-instr-generate"], .when(configuration: .debug)),
                .linkedLibrary("boringssl"),
                .linkedFramework("Foundation")
            ]),
        .target(
            name: "BaguetteBridge",
            dependencies: [
              .target(name: "Baguette")
            ],
            path: "platform-apple",
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ],
            linkerSettings: [
                .linkedFramework("Foundation")
            ]),
        .testTarget(
            name: "BaguetteBridgeTests",
            dependencies: [
                "BaguetteBridge"
            ],
            path: "test",
            exclude: [
                "baguette_test.cpp"
            ],
            sources: [
                "TestCase1.swift"
            ],
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ],
            linkerSettings: [
                .linkedFramework("Foundation", .when(platforms: [.iOS, .macOS, .macCatalyst])),
                .linkedFramework("XCTest")
            ])
    ],
    swiftLanguageVersions: [SwiftVersion.v5],
    cxxLanguageStandard: CXXLanguageStandard.cxx20
)
