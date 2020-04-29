import Fluent

struct ModelCreateInitial: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.eventLoop.flatten([
            database.schema(Device.schema)
                .id()
                .field(.devicePlatform, .string, .required)
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
                .create(),
            database.schema(DailyTracingKey.schema)
                .id()
                .field(.tracingKeyBatchId, .uuid, .required)
                .field(.key, .data, .required)
                .field(.dayNumber, .int, .required)
                .timestamps()
                .create(),
            database.schema(TrackingKeyBatchFormField.schema)
                .id()
                .field(.tracingKeyBatchId, .uuid, .required)
                .field(.fieldType, .string, .required)
                .field(.key, .string, .required)
                .field(.value, .string, .required)
                .timestamps()
                .create()
        ])
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.eventLoop.flatten([
            database.schema(Device.schema).delete(),
            database.schema(TracingKeyBatch.schema).delete(),
            database.schema(DailyTracingKey.schema).delete()
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
