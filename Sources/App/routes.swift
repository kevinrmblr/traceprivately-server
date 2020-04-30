import Fluent
import Vapor

func routes(_ app: Application) throws {
    let webController = TracingKeyBatchesWebController()
    app.get(use: webController.index)
    app.get("batch", ":key", use: webController.batchDetails)

    let restGroup = app.grouped("api")

    let deviceRestController = DeviceRestController(allowedAuthStrategies: [.free, .iOSDeviceId])
    restGroup.post("auth", use: deviceRestController.postAuthentication)
    restGroup.put("auth/pushtoken", use: deviceRestController.putPushToken)

    let authenticatedGroup = restGroup.grouped(DeviceAuthenticator())
    let tracingKeyRestController = TracingKeyRestController()

    authenticatedGroup.get("infected", use: tracingKeyRestController.get)
    authenticatedGroup.post("submit", use: tracingKeyRestController.post)
}
