import Foundation
import NIO

struct DefaultDeviceValidator: DeviceValidator {

    func validate(in loop: EventLoop, platform: DevicePlatform, key: String) -> EventLoopPromise<Bool> {
        let promise: EventLoopPromise<Bool> = loop.makePromise()
        promise.completeWith(.success(true))
        return promise
    }
}
