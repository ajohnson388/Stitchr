//
//  UIWindow+Bootstrap.swift
//  Stitcher
//
//  Created by Andrew Johnson on 12/27/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import UIKit

extension UIWindow {
    
    static func make() -> Self {
        return Self(frame: UIScreen.main.bounds)
    }
    
    func initApp() {
        let services = ServiceProvider.getServices()
        let controller = ContainerViewController.make(cache: services.cache, api: services.api)
        rootViewController = controller
        makeKeyAndVisible()
    }
}
