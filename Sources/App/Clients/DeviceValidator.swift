import Vapor

protocol DeviceValidator {
    func validate(in: EventLoop, platform: DevicePlatform, key: String) -> EventLoopPromise<Bool>
}
