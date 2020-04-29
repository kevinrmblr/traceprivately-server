import Fluent
import FluentSQLiteDriver
import Leaf
import MessagePack
import Vapor

// MARK: Application Configuration
public func configure(_ app: Application) throws {
    // Serves files from `Public/` directory
    app.middleware.use(FileMiddleware(publicDirectory: "Resources/Public/"))

    // Configure Leaf
    app.views.use(.leaf)
    app.leaf.cache.isEnabled = app.environment.isRelease

    // Local data setup
    app.databases.use(.sqlite(.file("traceprivately.sqlite")), as: .sqlite)
    app.migrations.add(ModelCreateInitial())

    // MSGPack support
    ContentConfiguration.global.use(encoder: MessagePackEncoder(), for: .msgPack)
    ContentConfiguration.global.use(decoder: MessagePackDecoder(), for: .msgPack)

    // Register Routes
    try routes(app)
}

extension Request {
    var deviceValidator: DeviceValidator { DummyDeviceValidator() }
}

// MARK: MessagePack Support

extension HTTPMediaType {
    static let msgPack = HTTPMediaType(type: "application", subType: "msgpack")
}

extension MessagePackEncoder: ContentEncoder {
    public func encode<E>(_ encodable: E, to body: inout ByteBuffer, headers: inout HTTPHeaders) throws where E: Encodable {
        headers.contentType = .msgPack
        try body.writeBytes(self.encode(encodable))
    }
}

extension MessagePackDecoder: ContentDecoder {
    public func decode<D>(_ decodable: D.Type, from body: ByteBuffer, headers: HTTPHeaders) throws -> D where D: Decodable {
        let data = body.getData(at: body.readerIndex, length: body.readableBytes) ?? Data()
        return try self.decode(D.self, from: data)
    }
}
