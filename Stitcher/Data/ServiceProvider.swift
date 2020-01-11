//
//  ServiceProvider.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/2/20.
//  Copyright © 2020 Meaningless. All rights reserved.
//

import Foundation

struct ServiceProvider {
    
    static var isTestEnviroment: Bool {
        return ProcessInfo.processInfo.environment["IS_TEST_ENV"] != nil
    }
    
    static func getServices() -> (cache: Cache, api: NetworkApi) {
        let cache = ServiceProvider.getCache()
        let api = ServiceProvider.getNetworkApi(cache: cache)
        return (cache, api)
    }
    
    static func getCache() -> Cache {
        return isTestEnviroment ? MockCache() : LocalCache()
    }
    
    static func getNetworkApi(cache: Cache = ServiceProvider.getCache()) -> NetworkApi {
        return isTestEnviroment ? NetworkApiMock(cache: cache) : SpotifyApi(cache: cache)
    }
}
