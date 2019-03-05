//
//  TablePresenter.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/29/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import UIKit
import DZNEmptyDataSet

/// The base delegate for the presenter that is used to trigger changes in data.
protocol BasePresenterDelegate: class {
    /// A callback that is triggered when the app's authorization state changes.
    ///
    /// - Parameter isAuthenticated: True if the user is authenticated.
    func isUserAuthenticatedDidChange(_ isAuthenticated: Bool)
    
    
    /// A callback that is triggered when the app experience an error.
    ///
    /// - Parameter error: The description of the error, or nil, if the error is no longer present.
    func errorDidChange(_ error: String?)
    
    
    /// A callback that is triggered when the app's loading state changes.
    ///
    /// - Parameter isLoading: True if the app is doing some work.
    func isLoadingChanged(_ isLoading: Bool)
}

/// An abstract base class for presenters that handles authorization, loading, and error states.
class BasePresenter: NSObject {
    
    /// The delegate used to trigger callbacks.
    weak var delegate: BasePresenterDelegate?
    
    /// The local cache used for storing credentials and user information.
    internal let cache: Cache
    
    /// The wrapper API around spotify responsible for processing requests.
    internal let spotifyApi: SpotifyApi
    
    /// Returns true if the user is authenticated.
    internal(set) var isAuthenticated: Bool {
        didSet {
            guard oldValue != isAuthenticated else {
                return
            }
            delegate?.isUserAuthenticatedDidChange(isAuthenticated)
        }
    }
    
    /// The current error experienced by the application, or nil, if there is no error.
    internal(set) var error: String? {
        didSet {
            delegate?.errorDidChange(error)
        }
    }
    
    /// Returns true if the application is currently doing some work.
    internal(set) var isLoading: Bool = false {
        didSet {
            delegate?.isLoadingChanged(isLoading)
        }
    }
    
    /// The designated initializer to instantiate the presenter object.
    ///
    /// - Parameters:
    ///   - cache: The local cache.
    ///   - spotifyApi: The spotify wrapper api.
    internal init(cache: Cache, spotifyApi: SpotifyApi = SpotifyApi()) {
        self.cache = cache
        self.spotifyApi = spotifyApi
        isAuthenticated = cache.userCredentials != nil
        super.init()
    }
    
    /// Makes a request to authrorize the app for Spotify via a system handler.
    func login() {
        spotifyApi.authorize()
    }
}


// MARK: - Cache Delegate

extension BasePresenter: CacheDelegate {
    
    func userCredentialsDidChange(_ credentials: TokenStore?) {
        isAuthenticated = credentials != nil
    }
}
