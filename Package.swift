// swift-tools-version:5.3
import PackageDescription
import Foundation

// in Xcode, this is '/'
let workspace = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
// let vcpkgInstalledURL = workspace.appendingPathComponent("build").appendingPathComponent("vcpkg_installed")

// see https://github.com/microsoft/vcpkg/blob/master/docs/users/manifests.md
// see .github/workflows/swift.yml
let vcpkgInstalledPath = "build/vcpkg_installed"

let package = Package(
  name: "scone",
  platforms: [
    // see https://developer.apple.com/documentation/swift_packages/supportedplatform/
    .macOS("11.0"), .iOS("13.0"), // macCatalyst("13.0"),
  ],
  products: [
    .library(name: "scone_native", type: .dynamic, targets: ["scone_native"]),
    .library(name: "scone", type: .dynamic, targets: ["scone"]),
  ],
  dependencies: [
    .package(
      name: "SwiftProtobuf", url: "https://github.com/apple/swift-protobuf.git",
      .exact("1.16.0"))
  ],
  targets: [
    .target(
      name: "scone_native", path: "",
      exclude: [
        "DerivedData", "build", "Tests",
        "Sources/sample.pb.swift"
      ],
      sources: [
        "Sources/binding.cpp",
        "Sources/sample.pb.cc",
        "Sources/sample.pb.h",
      ],
      publicHeadersPath: "Sources",
      cxxSettings: [
        // todo: macCatalyst
        .headerSearchPath("\(vcpkgInstalledPath)/x64-osx/include", .when(platforms: [.macOS])),
        .headerSearchPath("\(vcpkgInstalledPath)/arm64-osx/include", .when(platforms: [.iOS])),
        .define("_DEBUG", to: "1", .when(configuration: .debug)),
        .unsafeFlags(["-stdlib=libc++"]),
        .unsafeFlags(["-fcoroutines-ts"]),
      ],
      linkerSettings: [
        .linkedLibrary("protobuf-lited", .when(configuration: .debug)),
        .linkedLibrary("protobuf-lite", .when(configuration: .release)),
        // .linkedLibrary("fmtd", .when(configuration: .debug)),
        // .linkedLibrary("fmt", .when(configuration: .release)),
        .unsafeFlags(["-L\(vcpkgInstalledPath)/x64-osx/debug/lib"], .when(platforms: [.macOS], configuration: .debug)),
        .unsafeFlags(["-L\(vcpkgInstalledPath)/x64-osx/lib"], .when(platforms: [.macOS], configuration: .release)),
        .unsafeFlags(["-L\(vcpkgInstalledPath)/arm64-ios/debug/lib"], .when(platforms: [.iOS], configuration: .debug)),
        .unsafeFlags(["-L\(vcpkgInstalledPath)/arm64-ios/lib"], .when(platforms: [.iOS], configuration: .release)),
      ]
    ),
    .target(
      name: "scone", dependencies: ["SwiftProtobuf"], path: "Sources",
      exclude: [
        // "DerivedData", 
        "sample.pb.h",
        "sample.pb.cc"
      ],
      sources: [
        "sample.pb.swift",
      ],
      swiftSettings: [
        .define("_DEBUG", .when(configuration: .debug))
      ],
      linkerSettings: [
        .linkedFramework("Metal")  // for C++ based framework
      ]
    ),
    .testTarget(
      name: "sconeTests", dependencies: ["scone", "scone_native"], path: "Tests"
    ),
  ],
  swiftLanguageVersions: [SwiftVersion.v5],
  cLanguageStandard: CLanguageStandard.c11,
  cxxLanguageStandard: CXXLanguageStandard.cxx1z
)
