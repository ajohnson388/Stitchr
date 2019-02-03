//
//  TablePresenter.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/29/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import UIKit
import OAuthSwift
import DZNEmptyDataSet

protocol BasePresenterDelegate: class {
    func isUserAuthenticatedDidChange(_ isAuthenticated: Bool)
    func errorDidChange(_ error: String?)
    func isLoadingChanged(_ isLoading: Bool)
}

class BasePresenter: NSObject {
    
    weak var delegate: BasePresenterDelegate?
    
    internal let cache: Cache
    internal let spotifyApi: SpotifyApi
    
    internal(set) var isAuthenticated: Bool {
        didSet {
            delegate?.isUserAuthenticatedDidChange(isAuthenticated)
        }
    }
    internal(set) var error: String? {
        didSet {
            delegate?.errorDidChange(error)
        }
    }
    internal(set) var isLoading: Bool = false {
        didSet {
            delegate?.isLoadingChanged(isLoading)
        }
    }
    
    internal init(cache: Cache, spotifyApi: SpotifyApi = SpotifyApi()) {
        self.cache = cache
        self.spotifyApi = spotifyApi
        isAuthenticated = cache.userCredentials != nil
        super.init()
    }
    
    func login(viewController: UIViewController) {
        spotifyApi.authorize(viewController: viewController) { isAuthenticated in
            guard isAuthenticated else {
                self.isAuthenticated = false
                return
            }
            
            // Get the user profile now
            self.spotifyApi.getUserProfile { profile in
                self.cache.userId = profile?.id
                self.isAuthenticated = true
            }
        }
    }
}


extension BasePresenter: CacheDelegate {
    
    func userCredentialsDidChange(_ credentials: OAuthSwiftCredential?) {
        isAuthenticated = credentials != nil
    }
}
