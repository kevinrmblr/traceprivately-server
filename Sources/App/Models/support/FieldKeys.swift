import Fluent

extension FieldKey {

    // Timestamping
    static var createdAt: Self { "created_at" }
    static var updatedAt: Self { "updated_at" }
    static var deletedAt: Self { "deleted_at" }

    static var tokenExpirationDate: Self { "token_expiration_date" }

    // Identification
    static var token: Self { "token" }
    static var key: Self { "key" }

    // Tracing keys
    static var tracingKeyBatchId: Self { "tracing_key_batch_id" }
    static var dayNumber: Self { "day_number" }
    static var status: Self { "status" }
    static var fieldType: Self { "field_type" }
    static var value: Self { "value" }


    // Device
    static var devicePlatform: Self { "device_platform" }
    static var pushToken: Self { "push_token" }
    static var deviceId: Self { "device_id" }
}
