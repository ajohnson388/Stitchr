//
//  Cancellable.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/29/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import Alamofire

protocol Cancellable {
    func cancel()
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
