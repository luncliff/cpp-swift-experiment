
### References

* https://swift.org/package-manager/
* https://developer.apple.com/documentation/swift_packages
* https://github.com/apple/example-package-fisheryates
* https://github.com/microsoft/vcpkg/blob/master/docs/specifications/manifests.md
* https://github.com/apple/swift-protobuf
* https://developers.google.com/protocol-buffers/docs/reference/overview

## How To

### Setup

#### [Vcpkg](https://github.com/microsoft/vcpkg)

The project uses vcpkg "manifest" feature.

```bash
export VCPKG_FEATURE_FLAGS="manifests"
```

#### iOS CMake Toolchain

See https://github.com/leetal/ios-cmake. 4.1.1 or later will be fine.

```bash
pushd $HOME
    git clone --branch=4.1.1 https://github.com/leetal/ios-cmake
popd
```

#### Swift Protobuf

Check https://github.com/apple/swift-protobuf#converting-proto-files-into-swift

```
brew install swift-protobuf
```

### Build

Codegen uses `protoc` in vcpkg. CMakeLists.txt defines custom target `codegen` and library target `gloom_pb`.

#### Codegen: Mac

```bash
mkdir -p build && pushd build
    cmake .. -G Xcode \
        -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$(pwd)/install \
        -DCMAKE_TOOLCHAIN_FILE=${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake \
        -DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=$HOME/ios-cmake/ios.toolchain.cmake \
        -DPLATFORM=MAC \
        -DDEPLOYMENT_TARGET=11.0
    cmake --build . --target codegen  # invoke protoc to generate C++/Swift code
    cmake --build . --target gloom_pb # build with the installed library in vcpkg
popd
```

#### Codegen: iPhone

Change `PLATFORM` and `DEPLOYMENT_TARGET` for iPhone build. See ios.toolchain.cmake for more details.

```bash
mkdir -p build && pushd build
    cmake .. -G Xcode \
        -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$(pwd)/install \
        -DCMAKE_TOOLCHAIN_FILE=${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake \
        -DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=${HOME}/ios-cmake/ios.toolchain.cmake \
        -DPLATFORM=OS64 \
        -DDEPLOYMENT_TARGET=13.0
    cmake --build . --target codegen  # invoke protoc to generate C++/Swift code
    cmake --build . --target gloom_pb # build with the installed library in vcpkg
popd
```

#### Swift Pacakge

After the codegen steps, `swift build` and `swift test` will become available.
Check [Package.swift](./Package.swift).

Notice that we are using vcpkg's manifest feature. By doing so the `protobuf` library will be installed under "build/vcpkg_installed/...".

```
swift build --configuration debug
swift test
```

After test, run Release build.

```
swift build --configuration release
```

For iPhone build, see https://stackoverflow.com/a/62246008. You may need to generate xcodeproj and edit it to finish build.
