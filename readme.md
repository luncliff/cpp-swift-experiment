
[![CMake](https://github.com/luncliff/cpp-swift-experiment/actions/workflows/cmake.yml/badge.svg)](https://github.com/luncliff/cpp-swift-experiment/actions/workflows/cmake.yml)
[![Swift](https://github.com/luncliff/cpp-swift-experiment/actions/workflows/swift.yml/badge.svg)](https://github.com/luncliff/cpp-swift-experiment/actions/workflows/swift.yml)

### References

* https://swift.org/package-manager/
* https://swift.org/documentation/cxx-interop/project-build-setup/
* https://developer.apple.com/documentation/swift_packages
* https://developer.apple.com/documentation/objectivec/objective-c_runtime?language=objc
* https://learn.microsoft.com/en-us/vcpkg/consume/manifest-mode
* https://github.com/SonarSource/sonar-scanning-examples/tree/master/swift-coverage
* https://github.com/realm/SwiftLint

## How To

### Setup

```powershell
scripts/setup-metal-cpp.ps1 -Folder "externals" -FileName "metal-cpp_macOS15_iOS18.zip"
```

### Build

#### With Swift Package Manager(SwiftPM)

```bash
swift build --build-tests
swift build --configuration debug --target Baguette
```

#### With Xcodebuild

```bash
xcodebuild -showsdks
```

```bash
xcodebuild -list -workspace .
```

```bash
xcodebuild -workspace . -scheme "Baguette-Package" -showdestinations
```

```bash
xcodebuild -workspace . -scheme "Baguette-Package" \
    -destination "generic/platform=macOS" \
    -derivedDataPath DerivedData \
    -configuration Debug \
    build
```

#### With CMake, Vcpkg Toolchain

```bash
export VCPKG_FEATURE_FLAGS="manifests"
export VCPKG_ROOT="$HOME/../vcpkg"
```

```bash
cmake --preset x64-osx
cmake --build --preset x64-osx-debug
```

### Test

#### With SwiftPM

```bash
swift test --list-tests
swift test --enable-code-coverage
```

#### With Xcodebuild

```bash
xcodebuild -workspace . -scheme "Baguette-Package" \
    -destination "platform=macOS" \
    -derivedDataPath DerivedData \
    -enableCodeCoverage YES \
    test
```

#### With CMake, Vcpkg Toolchain

```bash
cmake --build --preset x64-osx-debug --target baguette_test
ctest --preset x64-osx-debug
```

### Analysis

* https://docs.sonarqube.org/latest/analyzing-source-code/analysis-parameters/
* https://docs.sonarcloud.io/enriching/test-coverage/test-coverage-parameters/
* https://medium.com/xcblog/xccov-xcode-code-coverage-report-for-humans-466a4865aa18

#### Coverage With llvm-cov & lcov

If you used Swift Package Manager to build/test, the path can be used with configuration name.

```bash
llvm-cov export --format lcov -instr-profile .build/debug/codecov/default.profdata .build/debug/BaguettePackageTests.xctest/Contents/MacOS/BaguettePackageTests > lcov.info
```

Xcodebuild will generate more complicated output path.

```bash
profdata_path=$(find "DerivedData/Build/ProfileData" -name "Coverage.profdata" | head -n 1)
xctest_path="DerivedData/Build/Products/Debug/BaguetteBridgeTests.xctest/Contents/MacOS/BaguetteBridgeTests"
llvm-cov export -format lcov -instr-profile "$profdata_path" "$xctest_path" > lcov.info
```

```ps1
$profdata_path = Get-ChildItem -File -Path "DerivedData/Build/ProfileData" -Recurse -Filter "Coverage.profdata" 
$xctest_path = "./DerivedData/Build/Products/Debug/BaguetteBridgeTests.xctest/Contents/MacOS/BaguetteBridgeTests"
llvm-cov export -format lcov -instr-profile "$profdata_path" "$xctest_path" > lcov.info
```

From the generated `lcov.info`, you can remove unnecessary files. 

```bash
lcov --remove lcov.info "test/" \
     --output-file lcov-changed.info
lcov --remove lcov-changed.info "externals/" \
     --output-file lcov-changed.info --ignore-errors unused
```

```bash
lcov --list lcov-changed.info
```

From the file, you can generate HTML report.

```bash
genhtml lcov.info --output-directory docs
open docs/index.html
```

Use xcrun to generate coverage report.

```bash
xcrun --run llvm-cov show -instr-profile=$profdata_path $xctest_path > docs/coverage.report
```

#### Coverage With xccov

```bash
xcresult_path=$(find DerivedData/Logs/Test/ -maxdepth 1 -name "Test*.xcresult" | head -n 1)
```

```ps1
$xcresult_path = Get-ChildItem -Directory  -Filter "DerivedData/Logs/Test/Test*.xcresult" | Select-Object -First 1
```

```bash
xcrun xccov view --report "$xcresult_path"
```

```bash
xcrun xccov view --report --json $xcresult_path | jq
```

```ps1
New-Item -Type Directory -Name "scripts" -Force
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SonarSource/sonar-scanning-examples/master/swift-coverage/swift-coverage-example/xccov-to-sonarqube-generic.sh" -OutFile "scripts/xccov-to-sonarqube-generic.sh"
```

```bash
bash ./scripts/xccov-to-sonarqube-generic.sh $xcresult_path > docs/coverage.xml
```

#### Reporting

(TBA)

### Lint

Check https://github.com/realm/SwiftLint

```bash
swiftlint lint --autocorrect
swiftlint lint --output docs/lint.md --reporter markdown
```

### Document

```bash
xcodebuild docbuild -workspace . -derivedDataPath DerivedData -scheme Baguette-Package -destination "platform=macOS"
find "$(pwd)/.build" -type d -name "*.doccarchive"
```
