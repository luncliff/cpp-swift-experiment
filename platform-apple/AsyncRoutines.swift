import Foundation
import Dispatch

/// @see https://developer.apple.com/documentation/dispatch/dispatchsemaphore/1452955-init
class AsyncRoutines {
  var handle: UnsafeMutableRawPointer?
  let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)

  @objc
  init() {
    handle = dlopen("libbaguette.dylib", RTLD_NOW)
    if handle == nil {
      handle = dlopen(nil, RTLD_NOW)
    }
  }

  deinit {
    dlclose(handle)
  }

  @objc
  func scheduleTask() {
    typealias FSchedule = @convention(c) (DispatchQueue, DispatchSemaphore) -> UInt32
    let fn = unsafeBitCast(dlsym(handle, "_ZN10experiment23something_in_backgroundEP16dispatch_queue_sP20dispatch_semaphore_s")!, to: FSchedule.self)
    let sem = DispatchSemaphore(value: 0)
    fn(queue, sem)
    print("scheduled")
    sem.wait()
    print("finished")
  }
}
