
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

See https://github.com/leetal/ios-cmake. 4.1.3 or later will be fine.

```bash
pushd $HOME
    git clone --branch=4.1.3 https://github.com/leetal/ios-cmake
popd
```

Or download the toolchain file with some tool.

```bash
wget https://raw.githubusercontent.com/leetal/ios-cmake/4.2.0/ios.toolchain.cmake
```

#### Swift Protobuf

Check https://github.com/apple/swift-protobuf#converting-proto-files-into-swift

```
brew install swift-protobuf
```

### Build

Codegen uses `protoc` in the vcpkg. Currently CMakeLists.txt defines 2 targets.

1. custom target `codegen`
2. library target `sample`

#### Codegen: Mac

```bash
mkdir -p build && pushd build
    cmake .. -G Xcode \
        -DBUILD_SHARED_LIBS=true \
        -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_TOOLCHAIN_FILE=${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake \
        -DVCPKG_TARGET_TRIPLET=x64-osx -DVCPKG_OSX_DEPLOYMENT_TARGET=11.0 \
        -DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=$HOME/ios-cmake/ios.toolchain.cmake \
        -DPLATFORM=MAC -DDEPLOYMENT_TARGET=11.0 
    cmake --build . --target codegen # invoke protoc to generate C++/Swift code
    cmake --build . --target scone_native # build with the installed protobuf library in vcpkg
popd
```

If build was successful, you can install it with CMAKE_INSTALL_PREFIX.

```bash
mkdir -p install
mkdir -p build && pushd build
    cmake .. -DCMAKE_INSTALL_PREFIX="$(pwd)/../install"
    cmake --build . --config Debug --target install
popd
```
This will report something like the following

```
...
-- Install configuration: "Debug"
-- Installing: /.../cpp-swift-experiment/install/include/sample.proto
-- Installing: /.../cpp-swift-experiment/install/lib/libscone_native.dylib
-- Installing: /.../cpp-swift-experiment/install/include/sample.pb.h

** BUILD SUCCEEDED **

```

#### Codegen: Mac Catalyst

> NOT TESTED yet...

ios-cmake supports MAC_CATALYST for its PLATFORM. Requires higher DEPLOYMENT_TARGET.

```bash
mkdir -p build && pushd build
    cmake .. -G Xcode \
        -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$(pwd)/install \
        -DCMAKE_TOOLCHAIN_FILE=${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake \
        -DVCPKG_TARGET_TRIPLET=x64-osx -DVCPKG_OSX_DEPLOYMENT_TARGET=13.0 \
        -DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=$HOME/ios-cmake/ios.toolchain.cmake \
        -DPLATFORM=MAC_CATALYST -DDEPLOYMENT_TARGET=13.0
    cmake --build . --target codegen # invoke protoc to generate C++/Swift code
    cmake --build . --target scone_native # build with the installed library in vcpkg
popd
```

#### Codegen: iPhone

Change PLATFORM and DEPLOYMENT_TARGET for iPhone build. 
See the comments in ios.toolchain.cmake for more details.

```bash
mkdir -p build && pushd build
    cmake .. -G Xcode \
        -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$(pwd)/install \
        -DCMAKE_TOOLCHAIN_FILE=${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake \
        -DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=${HOME}/ios-cmake/ios.toolchain.cmake \
        -DPLATFORM=OS64 \
        -DDEPLOYMENT_TARGET=13.0
    cmake --build . --target codegen  # invoke protoc to generate C++/Swift code
    cmake --build . --target scone_native # build with the installed library in vcpkg
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
