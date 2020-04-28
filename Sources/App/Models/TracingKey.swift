import Fluent
import Vapor

final class TracingKey: Model {
    static let schema = "tracing_key"

    @ID(key: .id)
    var id: UUID?

    @Field(key: .key)
    var key: Data

    @Parent(key: .tracingKeyBatchId)
    var batch: TracingKeyBatch

    @Timestamp(key: .createdAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: .updatedAt, on: .update)
    var updatedAt: Date?

    @Timestamp(key: .deletedAt, on: .delete)
    var deletedAt: Date?

    init() {}

    init(id: UUID? = nil, batchId: UUID, key: Data) {
        self.id = id
        self.key = key
        self.$batch.id = batchId
    }
}
