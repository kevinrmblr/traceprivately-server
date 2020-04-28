import Fluent
import Vapor

enum BatchStatus: String, Codable {
    case pending
    case rejected
    case confirmed
}

final class TracingKeyBatch: Model {
    static let schema = "tracing_key_batch"

    @ID(key: .id)
    var id: UUID?

    @Field(key: .key)
    var key: UUID

    @Parent(key: .deviceId)
    var device: Device

    @Field(key: .status)
    var status: BatchStatus

    @Children(for: \.$batch)
    var keys: [TracingKey]

    @Timestamp(key: .createdAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: .updatedAt, on: .update)
    var updatedAt: Date?

    @Timestamp(key: .deletedAt, on: .delete)
    var deletedAt: Date?

    init() {}

    init(id: UUID? = nil, deviceId: UUID, key: UUID = UUID.generateRandom(), status: BatchStatus = .pending) {
        self.id = id
        self.key = key
        self.status = status
        self.$device.id = deviceId
    }

    /// Workaround for: https://github.com/vapor/leaf-kit/issues/23
    var keyDump: String { keys.reduce("", { "\($0), \($1)" }) }
}
