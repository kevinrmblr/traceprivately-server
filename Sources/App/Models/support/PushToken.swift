import Foundation

enum PushToken: Codable {
    case ios(token: String)
    case android(token: String)
}

extension PushToken {
    private enum CodingKeys: String, CodingKey {
        case ios
        case android
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? values.decode(String.self, forKey: .ios) {
            self = .ios(token: value)
            return
        }
        if let value = try? values.decode(String.self, forKey: .android) {
            self = .android(token: value)
            return
        }
        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: values.codingPath,
                                                                debugDescription: "\(dump(values))"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .ios(token):
            try container.encode(token, forKey: .ios)
        case let .android(token):
            try container.encode(token, forKey: .android)
        }
    }
}
