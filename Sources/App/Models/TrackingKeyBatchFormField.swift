import Fluent
import Vapor

final class TrackingKeyBatchFormField: Model {
    enum FieldType: String, Codable {
        case text
    }

    static let schema = "tracing_key_batch_form_field"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: .tracingKeyBatchId)
    var batch: TracingKeyBatch

    @Field(key: .fieldType)
    var type: FieldType

    @Field(key: .key)
    var key: String

    @Field(key: .value)
    var value: String

    @Timestamp(key: .createdAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: .updatedAt, on: .update)
    var updatedAt: Date?

    @Timestamp(key: .deletedAt, on: .delete)
    var deletedAt: Date?

    init() {}

    init(id: UUID? = nil, batchId: UUID, type: FieldType, key: String, value: String) {
        self.id = id
        self.type = type
        self.key = key
        self.value = value
        self.$batch.id = batchId
    }
}
