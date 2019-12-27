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

@available(iOS 12.0, *)
extension UIViewController: ASWebAuthenticationPresentationContextProviding {
    
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window ?? ASPresentationAnchor()
    }
}
