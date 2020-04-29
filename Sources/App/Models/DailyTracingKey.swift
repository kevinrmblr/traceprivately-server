import Fluent
import Vapor

final class DailyTracingKey: Model {
    static let schema = "daily_tracing_key"

    @ID(key: .id)
    var id: UUID?

    @Field(key: .key)
    var key: Data

    @Field(key: .dayNumber)
    var dayNumber: Int

    @Parent(key: .tracingKeyBatchId)
    var batch: TracingKeyBatch

    @Timestamp(key: .createdAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: .updatedAt, on: .update)
    var updatedAt: Date?

    @Timestamp(key: .deletedAt, on: .delete)
    var deletedAt: Date?

    init() {}

    init(id: UUID? = nil, batchId: UUID, key: Data, dayNumber: Int) {
        self.id = id
        self.key = key
        self.dayNumber = dayNumber
        self.$batch.id = batchId
    }
}
