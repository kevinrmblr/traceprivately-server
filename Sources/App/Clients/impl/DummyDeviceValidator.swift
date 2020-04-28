//
//  File.swift
//  
//
//  Created by K Rummler on 24/04/2020.
//

import Vapor

/**
 Device validator that will always succeed
 */
struct DummyDeviceValidator: DeviceValidator {

    func validate(in loop: EventLoop, platform: DevicePlatform, key: String) -> EventLoopPromise<Bool> {
        let promise: EventLoopPromise<Bool> = loop.makePromise()
        promise.completeWith(.success(true))
        return promise
    }
}
