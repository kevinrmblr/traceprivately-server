import Fluent
import Vapor

final class Device: Model, Authenticatable {
    static let schema = "device"

    @ID(key: .id)
    var id: UUID?

    @Field(key: .token)
    var token: String

    @Field(key: .tokenExpirationDate)
    var tokenExpirationDate: Date

    @Field(key: .pushToken)
    var pushToken: PushToken?

    @Children(for: \.$device)
    var batches: [TracingKeyBatch]

    @Timestamp(key: .createdAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: .updatedAt, on: .update)
    var updatedAt: Date?

    @Timestamp(key: .deletedAt, on: .delete)
    var deletedAt: Date?

    init() {}

    init(id: UUID? = nil, token: String, tokenExpirationDate: Date) {
        self.id = id
        self.token = token
        self.tokenExpirationDate = tokenExpirationDate
    }
}
