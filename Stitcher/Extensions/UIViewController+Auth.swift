//
//  UIViewController+Auth.swift
//  Stitcher
//
//  Created by Andrew Johnson on 12/10/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import UIKit
import AuthenticationServices

extension UIViewController: ASWebAuthenticationPresentationContextProviding {
    
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window ?? ASPresentationAnchor()
    }
}
