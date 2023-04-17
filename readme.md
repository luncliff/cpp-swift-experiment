
[![Native: Mac](https://github.com/luncliff/cpp-swift-experiment/actions/workflows/native_mac.yml/badge.svg)](https://github.com/luncliff/cpp-swift-experiment/actions/workflows/native_mac.yml)
[![Swift: Mac](https://github.com/luncliff/cpp-swift-experiment/actions/workflows/swift_mac.yml/badge.svg)](https://github.com/luncliff/cpp-swift-experiment/actions/workflows/swift_mac.yml)

### References

* https://swift.org/package-manager/
* https://developer.apple.com/documentation/swift_packages
* https://developer.apple.com/documentation/objectivec/objective-c_runtime?language=objc
* https://github.com/microsoft/vcpkg/blob/master/docs/specifications/manifests.md

## How To

### Setup

```bash
pwsh setup-metal-cpp.ps1
```

### Build

#### With Swift Package Manager(SwiftPM)

```bash
swift build
swift build --configuration release --target baguette-target
```

```bash
# xcodebuild build -workspace . -list
xcodebuild build -workspace . -derivedDataPath .build -scheme bridging-Package -destination "platform=macOS,arch=x86_64"
```

#### With CMake, Vcpkg Toolchain

```bash
export VCPKG_FEATURE_FLAGS="manifests"
export VCPKG_ROOT="$HOME/../vcpkg"
```

```
cmake --preset=x64-osx
cmake --build --preset=x64-osx-debug
```

### Test

#### With SwiftPM

```bash
# swift test --list-tests
swift test
```

#### With CMake, Vcpkg Toolchain

```
cmake --build --preset=x64-osx-debug --target baguette_test
ctest --preset=x64-osx-debug
```

### Lint

Check https://github.com/realm/SwiftLint

```bash
swiftlint lint --autocorrect
swiftlint lint --output docs/lint.md --reporter markdown
```

### Document

```bash
xcodebuild docbuild -workspace . -derivedDataPath .build -scheme bridging-Package -destination "platform=macOS"
find "$(pwd)/.build" -type d -name "*.doccarchive"
```
