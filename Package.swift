// swift-tools-version: 5.5
import PackageDescription

let package = Package(
  name: "bridging",
  products: [
    .library(name: "baguette_static", type: .static, targets: ["baguette-target"]),
    .library(name: "baguette", type: .dynamic, targets: ["baguette-target"]),
    .executable(name: "baguette_test", targets: ["baguette_test"])
  ],
  targets: [
    .target(
      name: "baguette-target",
      path: "src",
      sources: [
        "bridge_apple.cpp",
        "bridge.hpp",
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
        .define("_DEBUG", to: "1", .when(configuration: .debug)),
        .define("USING_SWIFTPM")
      ],
      linkerSettings: [
        .linkedLibrary("boringssl"),
        .linkedFramework("Foundation")
      ]
    ),
    .target(
      name: "BaguetteBridge",
      dependencies: [
        .target(name: "baguette-target") // "baguette-target",
      ],
      path: "platform-apple",
      swiftSettings: [
        .define("USING_SWIFTPM")
      ],
      linkerSettings: [
        .linkedLibrary("boringssl"),
        .linkedFramework("Foundation")
      ]
    ),
    .testTarget(
      name: "BaguetteBridgeTests",
      dependencies: [
        "baguette-target",
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
        .define("USING_SWIFTPM")
      ],
      linkerSettings: [
        .linkedFramework("XCTest", .when(platforms: [.iOS, .macOS, .macCatalyst])),
        .linkedFramework("Foundation")
      ]
    ),
    .executableTarget(
      name: "baguette_test",
      dependencies: [
        "baguette-target",
        "BaguetteBridge"
      ],
      path: "test",
      exclude: [
        "TestCase1.swift"
      ],
      sources: [
        "baguette_test.cpp"
      ],
      cxxSettings: [
        .headerSearchPath("../externals/metal-cpp"),
        .define("_DEBUG", to: "1", .when(configuration: .debug)),
        .define("USING_SWIFTPM")
      ],
      linkerSettings: [
        .linkedFramework("Foundation")
      ]
    )
  ],
  swiftLanguageVersions: [SwiftVersion.v5],
  cLanguageStandard: CLanguageStandard.c18,
  cxxLanguageStandard: CXXLanguageStandard.cxx20
)
