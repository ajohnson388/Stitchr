//
//  SpotifyApi.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/23/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import Alamofire
import OAuthSwift

final class SpotifyApi {
    
    static let shared = SpotifyApi()
    
    private static let clientId = "1a0445c72ddd4934a8835cef2baf1a0c"
    private static let clientSecret = "8875eec5f88c4154b39cbc3b045ddef2"
    private static let redirectUri = "com.meaningless.Stitcher://oauth"
    private static let accountsBaseUrl = "https://accounts.spotify.com/"
    private static let apiBaseUrl = "https://api.spotify.com/v1/"
    private static let permissionScopes = [
        "playlist-read-private",
        "playlist-modify-private",
        "playlist-modify-public",
        "playlist-read-collaborative",
        "user-read-birthdate",
        "user-read-email",
        "user-read-private"
    ]
    
    let oAuth = OAuth2Swift(
        consumerKey: clientId,
        consumerSecret: clientSecret,
        authorizeUrl: accountsBaseUrl + "authorize",
        accessTokenUrl: accountsBaseUrl + "token",
        responseType: "token"
    )
    
    private init() {}
    
    
    // MARK: - Accounts API
    
    func authorize(viewController: ViewController, completion: @escaping (Bool) -> ()) {
        guard let redirectUrl = URL(string: SpotifyApi.redirectUri) else {
            Logger.log("Failed to create the redirect url")
            return
        }
        
        oAuth.allowMissingStateCheck = true
        oAuth.authorizeURLHandler = SafariURLHandler(viewController: viewController, oauthSwift: oAuth)
        oAuth.authorize(
            withCallbackURL: redirectUrl,
            scope: SpotifyApi.permissionScopes.joined(separator: " "),
            state: "SPOTIFY",
            success: { credential, response, parameters in
                Cache.shared.isUserAuthorized = true
                completion(true)
            },
            failure: { error in
                Logger.log(error)
                completion(false)
            }
        )
    }
    
    
    // MARK: - User API
    
    func getUserProfile(completion: @escaping (UserProfile?) -> ()) {
        makeRequest(url: SpotifyApi.apiBaseUrl + "me", method: .GET, completion: completion)
    }
    
    func getPlaylists(offset: Int = 0, limit: Int = 20, completion: @escaping (PagingResponse?) -> ()) {
        let url = SpotifyApi.apiBaseUrl + "me/playlists"
        let parameters = ["offset": offset, "limit": limit]
        makeRequest(url: url, method: .GET, parameters: parameters, completion: completion)
    }
    
    func createPlaylist(name: String, userId: String, completion: @escaping (Playlist?) -> ()) {
        let url = SpotifyApi.apiBaseUrl + "users/\(userId)/playlists"
        makeRequest(url: url, method: .POST, parameters: ["name": name], completion: completion)
    }
    
    func addTracksToPlaylist(withId id: String, uris: [String], userId: String, completion: @escaping (SnapshotResponse?) -> ()) {
        let url = SpotifyApi.apiBaseUrl + "playlists/\(userId)/tracks"
        let parameters = ["uris": uris.joined(separator: ",")]
        makeRequest(url: url, method: .POST, parameters: parameters, completion: completion)
    }
    
    func removeTracksFromPlaylist(withId id: String, uris: [String], userId: String, completion: @escaping (SnapshotResponse?) -> ()) {
        let url = SpotifyApi.apiBaseUrl + "playlists/\(userId)/tracks"
        let parameters = ["tracks": uris.joined(separator: ",")]
        makeRequest(url: url, method: .DELETE, parameters: parameters, completion: completion)
    }
    
    private func makeRequest<T>(
        url: String, method: OAuthSwiftHTTPRequest.Method,
        parameters: OAuthSwift.Parameters? = nil, body: [String: Any]? = nil,
        completion: @escaping (T?) -> ()) where T: Decodable {
        
        let data = body == nil ? nil : try? JSONSerialization.data(withJSONObject: body as Any, options: [])
        oAuth.startAuthorizedRequest(
            url,
            method: method,
            parameters: parameters ?? [:],
            body: data,
            success: { response in
                    let object = T.decode(data: response.data)
                    completion(object)
            },
            failure: { error in
                Logger.log(error)
                completion(nil)
            }
        )
    }
}
