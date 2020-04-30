import Vapor

enum DevicePlatform {
    case ios, android
}

protocol DeviceValidator {

    func validate(in: EventLoop, platform: DevicePlatform, key: String) -> EventLoopPromise<Bool>
}
