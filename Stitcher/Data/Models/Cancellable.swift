//
//  Cancellable.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/29/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import OAuthSwift
import Alamofire

protocol Cancellable {
    func cancel()
}

struct CancellableRequest: Cancellable {
    
    private let request: OAuthSwiftRequestHandle
    
    func cancel() {
        request.cancel()
    }
    
    init(_ request: OAuthSwiftRequestHandle) {
        self.request = request
    }
}

struct CancellableAlamofireRequest: Cancellable {
    
    private let request: DataRequest
    
    func cancel() {
        request.cancel()
    }
    
    init(_ request: DataRequest) {
        self.request = request
    }
}
