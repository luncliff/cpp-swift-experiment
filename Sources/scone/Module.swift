import Environment
import Foundation

class Module {
    let envs = Environment.environment
    var handle: UnsafeMutableRawPointer?

    init() {
        var name: String? = envs["MODULE_NAME"]
        if name == nil {
            name = "scone_native"
        }
        handle = dlopen("lib\(name!).dylib", RTLD_NOW)
        if handle == nil {
            handle = dlopen(nil, RTLD_NOW)
        }
    }

    deinit {
        dlclose(handle)
    }

    func getAddress(name: String) -> UnsafeMutableRawPointer? {
        return dlsym(handle, name)
    }
}
