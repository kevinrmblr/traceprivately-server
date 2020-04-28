import Fluent
import FluentSQLiteDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) throws {

    // Serves files from `Public/` directory
    app.middleware.use(FileMiddleware(publicDirectory: "Resources/Public/"))

    // Configure Leaf
    app.views.use(.leaf)
    app.leaf.cache.isEnabled = app.environment.isRelease

    app.databases.use(.sqlite(.file("traceprivately.sqlite")), as: .sqlite)

    app.migrations.add(ModelCreateInitial())

    // register routes
    try routes(app)
}

extension Request {
    var deviceValidator: DeviceValidator { DummyDeviceValidator() }
}
