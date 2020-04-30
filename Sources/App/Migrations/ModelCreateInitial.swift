import Fluent

struct ModelCreateInitial: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.eventLoop.flatten([
            database.schema(Device.schema)
                .id()
                .field(.pushToken, .string)
                .field(.token, .string, .required)
                .field(.tokenExpirationDate, .datetime, .required)
                .timestamps()
                .create(),
            database.schema(TracingKeyBatch.schema)
                .id()
                .field(.key, .uuid, .required)
                .field(.deviceId, .uuid, .required)
                .field(.status, .string, .required)
                .timestamps()
                .foreignKey(.deviceId, references: Device.schema, .id)
                .create(),
            database.schema(DailyTracingKey.schema)
                .id()
                .field(.key, .data, .required)
                .field(.tracingKeyBatchId, .uuid, .required)
                .field(.dayNumber, .int, .required)
                .field(.riskLevel, .int, .required)
                .timestamps()
                .foreignKey(.tracingKeyBatchId, references: TracingKeyBatch.schema, .id)
                .create(),
            database.schema(TrackingKeyBatchFormField.schema)
                .id()
                .field(.key, .string, .required)
                .field(.tracingKeyBatchId, .uuid, .required)
                .field(.fieldType, .string, .required)
                .field(.value, .string, .required)
                .timestamps()
                .foreignKey(.tracingKeyBatchId, references: TracingKeyBatch.schema, .id)
                .create()
        ])
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.eventLoop.flatten([
            database.schema(Device.schema).delete(),
            database.schema(TrackingKeyBatchFormField.schema).delete(),
            database.schema(DailyTracingKey.schema).delete(),
            database.schema(TracingKeyBatch.schema).delete()
        ])
    }
}

private extension SchemaBuilder {
    func timestamps() -> Self {
        return self
            .field(.createdAt, .datetime, .required)
            .field(.updatedAt, .datetime, .required)
            .field(.deletedAt, .datetime)
    }
}
