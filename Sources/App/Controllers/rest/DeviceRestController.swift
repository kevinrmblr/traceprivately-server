import Fluent
import Vapor

struct DeviceRestController {
    let allowedAuthStrategies: [AuthStrategyRequestDTO]
    let tokenValidity: TimeInterval

    init(allowedAuthStrategies: [AuthStrategyRequestDTO],
         tokenValidity: TimeInterval = TimeInterval(60 * 60 * 24 * 7)) {
        self.allowedAuthStrategies = allowedAuthStrategies
        self.tokenValidity = tokenValidity
    }

    func postAuthentication(_ req: Request) throws -> EventLoopFuture<AuthResponseDTO> {
        let requestDTO = try? req.content.decode(AuthRequestDTO.self)
        guard allowedAuthStrategies.contains(.free) ||
            requestDTO?.isValid(for: allowedAuthStrategies) ?? false else {
            throw Abort(.badRequest)
        }

        let newDevice = Device(token: UUID().uuidString,
                               tokenExpirationDate: Date().advanced(by: tokenValidity))

        return newDevice.save(on: req.db).map {
            AuthResponseDTO(status: .ok, token: newDevice.token, expiresAt: newDevice.tokenExpirationDate)
        }
    }

    func putPushToken(_ req: Request) throws -> EventLoopFuture<HTTPResponseStatus> {
        guard let dto: PushTokenRequestDTO = try? req.content.decode(PushTokenRequestDTO.self),
            let device: Device = req.auth.get() else {
            throw Abort(.badRequest)
        }

        switch dto.platform {
        case .ios: device.pushToken = PushToken.ios(token: dto.token)
        case .android: device.pushToken = PushToken.android(token: dto.token)
        }

        return device.save(on: req.db).map { HTTPResponseStatus.ok }
    }
}

extension DeviceRestController {
    enum AuthStrategyRequestDTO: String, Content {
        case free = "FREE"
        case iOSDeviceId = "IOS_DEVICE_ID"
    }

    struct AuthRequestDTO: Content {
        let strategy: AuthStrategyRequestDTO
        let token: String?
    }

    struct AuthResponseDTO: Content {
        let status: ReponseStatusDTO
        let token: String
        let expiresAt: Date

        enum CodingKeys: String, CodingKey {
            case status, token
            case expiresAt = "expires_at"
        }
    }

    struct PushTokenRequestDTO: Content {
        let token: String
        let platform: DevicePlatform
    }

    enum DevicePlatform: String, Content {
        case ios = "IOS"
        case android = "ANDROID"
    }
}

private extension DeviceRestController.AuthRequestDTO {
    func isValid(for options: [DeviceRestController.AuthStrategyRequestDTO]) -> Bool {
        guard options.contains(strategy) else { return false }
        switch strategy {
        case .free: return true
        case .iOSDeviceId: return !(token?.isEmpty ?? true)
        }
    }
}

private extension DeviceRestController.AuthStrategyRequestDTO {
    var platform: DevicePlatform? {
        switch self {
        case .iOSDeviceId: return .ios
        case .free: return nil
        }
    }
}
