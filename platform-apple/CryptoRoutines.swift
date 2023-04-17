import Foundation

class SHA256Encoder {
  typealias FInit = @convention(c) (UnsafeMutableRawPointer) -> Int
  var SHA256Init: FInit
  typealias FUpdate = @convention(c) (UnsafeMutableRawPointer, UnsafeRawPointer, UInt) -> Int
  var SHA256Update: FUpdate
  typealias FFinal = @convention(c) (UnsafeMutableRawPointer, UnsafeMutableRawPointer) -> Int
  var SHA256Final: FFinal

  let ctx = UnsafeMutableRawPointer.allocate(byteCount: 200, alignment: 8)

  init(handle: UnsafeMutableRawPointer) {
    let fn1: UnsafeMutableRawPointer = dlsym(handle, "SHA256_Init")
    SHA256Init = unsafeBitCast(fn1, to: FInit.self)
    let fn2 = dlsym(handle, "SHA256_Update")
    SHA256Update = unsafeBitCast(fn2, to: FUpdate.self)
    let fn3 = dlsym(handle, "SHA256_Final")
    SHA256Final = unsafeBitCast(fn3, to: FFinal.self)
  }

  deinit {
    ctx.deallocate()
  }

  func encode(data: UnsafeRawPointer, length: UInt) -> NSData {
    let empty = NSData()
    if SHA256Init(ctx) == 0 {
      return empty
    }
    if SHA256Update(ctx, data, length) == 0 {
      return empty
    }
    var output = Data(count: 32)
    let buf = output.withUnsafeMutableBytes { blob in
      blob
    }
    if SHA256Final(buf.baseAddress!, ctx) == 0 {
      return empty
    }
    return NSMutableData(bytes: buf.baseAddress!, length: output.count)
  }
}

/// @see https://github.com/apple/swift-nio-ssl
class CryptoRoutines {
  var handle: UnsafeMutableRawPointer?

  @objc
  init() throws {
    handle = dlopen("libboringssl.dylib", RTLD_NOW)
    if handle == nil {
      handle = dlopen("/usr/lib/libboringssl.dylib", RTLD_NOW)
    }
  }

  deinit {
    dlclose(handle)
  }

  @objc
  func hashSHA256(text: String) -> NSData {
    let encoder = SHA256Encoder(handle: handle!)
    let u8text = text.utf8CString
    return u8text.withUnsafeBytes { bytes in
      encoder.encode(data: bytes.baseAddress!, length: UInt(u8text.count))
    }
  }
}
