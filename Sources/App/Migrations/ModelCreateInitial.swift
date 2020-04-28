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
                .field(.createdAt, .datetime, .required)
                .field(.updatedAt, .datetime, .required)
                .field(.deletedAt, .datetime)
                .create(),
            database.schema(TracingKeyBatch.schema)
                .id()
                .field(.key, .uuid, .required)
                .field(.deviceId, .uuid, .required)
                .field(.status, .string, .required)
                .field(.createdAt, .datetime, .required)
                .field(.updatedAt, .datetime, .required)
                .field(.deletedAt, .datetime)
                .create(),
            database.schema(TracingKey.schema)
                .id()
                .field(.tracingKeyBatchId, .string, .required)
                .field(.key, .data, .required)
                .field(.createdAt, .datetime, .required)
                .field(.updatedAt, .datetime, .required)
                .field(.deletedAt, .datetime)
                .create()
        ])
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.eventLoop.flatten([
            database.schema(Device.schema).delete(),
            database.schema(TracingKeyBatch.schema).delete(),
            database.schema(TracingKey.schema).delete()
        ])
    }
}
