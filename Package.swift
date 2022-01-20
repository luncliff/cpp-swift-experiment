// swift-tools-version:5.3
import PackageDescription

import Foundation

// see https://github.com/microsoft/vcpkg/blob/master/docs/users/manifests.md
// see .github/workflows/swift.yml
let installPath = "/Users/luncliff/vcpkg/installed"

let package = Package(
  name: "scone",
  platforms: [
    // see https://developer.apple.com/documentation/swift_packages/supportedplatform/
    .macOS("11.0"), .iOS("13.0"),
  ],
  // products: [
  //   .library(name: "scone_native", type: .dynamic, targets: ["scone_native"]),
  //   .library(name: "scone", type: .dynamic, targets: ["scone"]),
  // ],
  dependencies: [
    .package(name: "Environment", url: "https://github.com/wlisac/environment.git", .exact("0.11.1")),
    .package(name: "SwiftProtobuf", url: "https://github.com/apple/swift-protobuf.git", .exact("1.18.0")),
  ],
  targets: [
    .target(
      name: "scone_native",
      publicHeadersPath: "scone_native",
      cxxSettings: [
        .headerSearchPath("externals/include"),
        .unsafeFlags(["-I\(installPath)/x64-osx/include"], .when(platforms: [.macOS])),
        .unsafeFlags(["-I\(installPath)/arm64-ios/include"], .when(platforms: [.iOS])),
        .define("_DEBUG", to: "1", .when(configuration: .debug)),
        .unsafeFlags(["-stdlib=libc++"]),
        .unsafeFlags(["-fcoroutines-ts"]),
      ],
      linkerSettings: [
        .linkedLibrary("protobuf-lited", .when(configuration: .debug)),
        .linkedLibrary("protobuf-lite", .when(configuration: .release)),
        .unsafeFlags(["-L\(installPath)/x64-osx/debug/lib"], .when(platforms: [.macOS], configuration: .debug)),
        .unsafeFlags(["-L\(installPath)/x64-osx/lib"], .when(platforms: [.macOS], configuration: .release)),
        .unsafeFlags(["-L\(installPath)/arm64-ios/debug/lib"], .when(platforms: [.iOS], configuration: .debug)),
        .unsafeFlags(["-L\(installPath)/arm64-ios/lib"], .when(platforms: [.iOS], configuration: .release)),
      ]
    ),
    .testTarget(
      name: "scone_nativeTests", dependencies: ["scone_native", "Environment"]
    ),
    .target(
      name: "scone", dependencies: ["scone_native", "SwiftProtobuf", "Environment"],
      swiftSettings: [
        .define("_DEBUG", .when(configuration: .debug)),
      ],
      linkerSettings: [
        .linkedFramework("Foundation"),
      ]
    ),
    .testTarget(
      name: "sconeTests", dependencies: ["scone", "Environment"]
    ),
  ],
  swiftLanguageVersions: [SwiftVersion.v5],
  cLanguageStandard: CLanguageStandard.c11, // c17, c18 requires 5.4
  cxxLanguageStandard: CXXLanguageStandard.cxx1z // cxx17, cxx20 requires 5.4
)
