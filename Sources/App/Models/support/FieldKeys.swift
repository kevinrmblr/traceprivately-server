import Fluent

extension FieldKey {
    static var createdAt: Self { "created_at" }
    static var updatedAt: Self { "updated_at" }
    static var deletedAt: Self { "deleted_at" }

    static var tracingKeyBatchId: Self { "tracing_key_batch_id" }
    static var deviceId: Self { "device_id" }
    static var key: Self { "key" }
    static var token: Self { "token" }
    static var tokenExpirationDate: Self { "token_expiration_date" }
    static var status: Self { "status" }
    static var pushToken: Self { "push_token" }
    static var devicePlatform: Self { "device_platform" }
}
