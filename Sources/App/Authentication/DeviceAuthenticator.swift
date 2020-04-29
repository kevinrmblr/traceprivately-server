//
//  
//  Created by kevinrmblr
//

import Fluent
import Vapor

struct DeviceAuthenticator: BearerAuthenticator {
    func authenticate(bearer: BearerAuthorization, for request: Request) -> EventLoopFuture<Void> {
        Device.query(on: request.db).filter(\.$token == bearer.token).first().map { device in
            if let device = device {
                request.auth.login(device)
            }
        }
    }
}
