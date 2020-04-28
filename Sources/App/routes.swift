import Fluent
import Vapor

func routes(_ app: Application) throws {
    let webController = InfectedWebController()
    app.get(use: webController.index)

    let deviceRestController = DeviceRestController(allowedAuthStrategies: [.iOSDeviceId])
    app.post("auth", use: deviceRestController.postAuthentication)
    app.put("auth/pushtoken", use: deviceRestController.putPushToken)

    let authenticatedGroup = app.grouped(DeviceAuthenticator())

    let tracingKeyRestController = TracingKeyRestController()
    authenticatedGroup.get("infected", use: tracingKeyRestController.get)
    authenticatedGroup.post("submit", use: tracingKeyRestController.post)
//    app.delete("submit", use: restController.delete)
}
