import Foundation

final class Log {
    typealias FnPrint = @convention(c) (UInt32, UnsafePointer<CChar>?) -> Void
    let module = Module()
    var print: FnPrint?

    init() {
        print = unsafeBitCast(module.getAddress(name: ""), to: FnPrint.self)
    }

    func debug(message: String) {
        let txt: UnsafePointer<CChar>? = (message as NSString).utf8String
        print?(1, txt)
    }

    func info(message: String) {
        let txt: UnsafePointer<CChar>? = (message as NSString).utf8String
        print?(2, txt)
    }

    func warn(message: String) {
        let txt: UnsafePointer<CChar>? = (message as NSString).utf8String
        print?(3, txt)
    }

    func error(message: String) {
        let txt: UnsafePointer<CChar>? = (message as NSString).utf8String
        print?(4, txt)
    }
}
