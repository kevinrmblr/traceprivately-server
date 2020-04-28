import Fluent
import Vapor

struct DeviceRestController {
    private struct Constants {
        static let tokenValidity = TimeInterval(60 * 60 * 24 * 7) // roughly 7 days
    }

    let allowedAuthStrategies: [AuthStrategyRequestDTO]

    init(allowedAuthStrategies: [AuthStrategyRequestDTO]) {
        self.allowedAuthStrategies = allowedAuthStrategies
    }

    func postAuthentication(_ req: Request) throws -> EventLoopFuture<AuthResponseDTO> {
        guard let dto: AuthRequestDTO = try? req.content.decode(AuthRequestDTO.self),
            allowedAuthStrategies.contains(dto.strategy),
            dto.isValid else {
            throw Abort(.badRequest)
        }

        let newDevice = Device(token: UUID().uuidString, tokenExpirationDate: Date().advanced(by: Constants.tokenValidity))
        newDevice.platform = .ios

        return newDevice.save(on: req.db).map {
            AuthResponseDTO(status: .ok, token: newDevice.token, expiresAt: newDevice.tokenExpirationDate)
        }
    }

    func putPushToken(_ req: Request) throws -> EventLoopFuture<HTTPResponseStatus> {
        guard let dto: PushTokenRequestDTO = try? req.content.decode(PushTokenRequestDTO.self),
            let device: Device = req.auth.get() else {
            throw Abort(.badRequest)
        }

        switch device.platform {
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

        var isValid: Bool {
            switch strategy {
            case .free: return true
            case .iOSDeviceId: return !(token?.isEmpty ?? true)
            }
        }
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
    }
}
