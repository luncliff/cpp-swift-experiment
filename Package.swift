// swift-tools-version:5.2
import PackageDescription

let cachePath = "build/vcpkg_installed"
let package = Package(
  name: "gloom",
  platforms: [
    .macOS("11.0"), .iOS("12.3"),
  ],
  products: [
    .library(name: "gloom_pb", type: .dynamic, targets: ["gloom_pb"]),
    .library(name: "Gloom", type: .dynamic, targets: ["Gloom"]),
  ],
  dependencies: [
    .package(
      name: "SwiftProtobuf", url: "https://github.com/apple/swift-protobuf.git",
      .exact("1.16.0"))
  ],
  targets: [
    .target(
      name: "gloom_pb", path: "",
      sources: [
        "build/sample.pb.cc",
        "build/sample.pb.h",
      ],
      publicHeadersPath: "build",
      cxxSettings: [
        .headerSearchPath("\(cachePath)/x64-osx/include", .when(platforms: [.macOS])),
        .define("_DEBUG", to: "1", .when(configuration: .debug)),
      ],
      linkerSettings: [
        .linkedLibrary("protobuf-lited", .when(configuration: .debug)),
        .linkedLibrary("protobuf-lite", .when(configuration: .release)),
        .unsafeFlags(
          ["-L\(cachePath)/x64-osx/debug/lib"],
          .when(platforms: [.macOS], configuration: .debug)),
        .unsafeFlags(
          ["-L\(cachePath)/arm64-ios/debug/lib"],
          .when(platforms: [.iOS], configuration: .debug)),
        .unsafeFlags(
          ["-L\(cachePath)/x64-osx/lib"],
          .when(platforms: [.macOS], configuration: .release)),
        .unsafeFlags(
          ["-L\(cachePath)/arm64-ios/lib"],
          .when(platforms: [.iOS], configuration: .release)),
      ]
    ),
    .target(
      name: "Gloom", dependencies: ["SwiftProtobuf"], path: "",
      sources: [
        "Sources/sample.pb.swift",
      ],
      swiftSettings: [
        .define("_DEBUG", .when(configuration: .debug))
      ],
      linkerSettings: [
        .linkedFramework("Metal")  // for C++ based framework
      ]
    ),
    .testTarget(
      name: "GloomTests", dependencies: ["Gloom", "gloom_pb"], path: "Tests"
    ),
  ],
  swiftLanguageVersions: [SwiftVersion.v5],
  cLanguageStandard: CLanguageStandard.c11,
  cxxLanguageStandard: CXXLanguageStandard.cxx1z
)
