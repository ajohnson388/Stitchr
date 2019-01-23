//
//  SpotifyApi.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/23/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import Alamofire

class SpotifyApi {
    
    private let clientId = ""
    private let authToken = ""
    private let redirectUri = "com.meaningless.powerhour://callback"
    private let accountsBaseUrl = "https://accounts.spotify.com/"
    private let apiBaseUrl = "https://api.spotify.com/v1/"
    private let permissionScopes = [
        "playlist-read-private",
        "playlist-modify-private",
        "playlist-modify-public",
        "playlist-read-collaborative"
    ]
    
    func requestAccessToken(code: String, completion: @escaping (TokenResponse?) -> ()) {
        let parameters = [
            "code": code,
            "grant_type": "authorization_code",
            "redirect_uri": redirectUri
        ]
        requestToken(parameters: parameters, completion: completion)
    }
    
    func requestRefreshToken(refreshToken: String, completion: @escaping (TokenResponse?) -> ()) {
        let parameters = [
            "refresh_token": refreshToken,
            "grant_type": "refresh_token",
        ]
        requestToken(parameters: parameters, completion: completion)
    }
    
    private func requestToken(parameters: [String: String], completion: @escaping (TokenResponse?) -> ()) {
        guard let url = URL(string: accountsBaseUrl + "api/token") else {
            completion(nil)
            return
        }
        
        var parameters = parameters
        parameters["client_id"] = clientId
        parameters["client_secret"] = authToken
        
        request(url, method: .post, parameters: parameters).validate().responseData { response in
            completion(TokenResponse.decode(data: response.data))
        }
    }
}
