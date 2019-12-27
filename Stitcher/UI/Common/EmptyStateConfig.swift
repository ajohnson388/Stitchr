//
//  EmptyStateConfig.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/31/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import UIKit

struct EmptyStateConfig {
    var state: State? = nil
    var title: String? = nil
    var description: String? = nil
    var image: UIImage? = nil
    var buttonTitle: String? = nil
    
    private init() {}
    
    enum State {
        case loading, error, authenticationChallenge, empty
    }
    
    static func makeLoading() -> EmptyStateConfig {
        var config = EmptyStateConfig()
        config.state = .loading
        config.image = Images.loadingImage
        return config
    }
    
    static func makeError(message: String) -> EmptyStateConfig {
        var config = EmptyStateConfig()
        config.state = .error
        config.title = Strings.errorTitle.localized
        config.description = message
        config.buttonTitle = Strings.errorButtonTitle.localized
        return config
    }
    
    static func makeAuthorization(message: String) -> EmptyStateConfig {
        var config = EmptyStateConfig()
        config.state = .error
        config.title = Strings.errorTitle.localized
        config.description = message
        config.buttonTitle = Strings.errorButtonTitle.localized
        return config
    }
    
    static func makeAuthorization() -> EmptyStateConfig {
        var config = EmptyStateConfig()
        config.state = .authenticationChallenge
        config.title = Strings.loginRequiredTitle.localized
        config.description = Strings.loginRequiredDescription.localized
        config.image = Images.spotifyLogo.make()
        config.buttonTitle = Strings.loginRequiredButtonTitle.localized
        return config
    }
    
    static func makeEmpty() -> EmptyStateConfig {
        var config = EmptyStateConfig()
        config.state = .empty
        return config
    }
}
