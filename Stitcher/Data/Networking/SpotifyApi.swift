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
import SafariServices

final class SpotifyApi {
    
    private static let redirectUri = "com.andyjohnson.stitchr://oauth"
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
        consumerKey: BuildConfig.spotifyClientId,
        consumerSecret: BuildConfig.spotifyClientSecret,
        authorizeUrl: accountsBaseUrl + "authorize",
        accessTokenUrl: accountsBaseUrl + "token",
        responseType: "token"
    )
    
    private let cache: Cache
    
    init(cache: Cache = LocalCache()) {
        self.cache = cache
        if let credentials = cache.userCredentials {
            oAuth.client.credential.oauthToken = credentials.oauthToken
            oAuth.client.credential.oauthRefreshToken = credentials.oauthRefreshToken
            oAuth.client.credential.oauthTokenExpiresAt = credentials.oauthTokenExpiresAt
        }
    }
    
    
    // MARK: - Accounts API
    
    func authorize(viewController: UIViewController, completion: @escaping (Bool) -> ()) {
        guard let redirectUrl = URL(string: SpotifyApi.redirectUri) else {
            Logger.log("Failed to create the redirect url")
            return
        }
        
        oAuth.allowMissingStateCheck = true
        
        let safariHandler = SafariURLHandler(viewController: viewController, oauthSwift: oAuth)
        safariHandler.factory = { url in
            let controller = SFSafariViewController(url: url)
            Themes.current.apply(safariViewController: controller)
            return controller
        }
        oAuth.authorizeURLHandler = safariHandler

        oAuth.authorize(
            withCallbackURL: redirectUrl,
            scope: SpotifyApi.permissionScopes.joined(separator: " "),
            state: "SPOTIFY",
            success: { credential, response, parameters in
                self.cache.isUserAuthorized = true
                self.cache.userCredentials = credential
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
        _ = makeRequest(url: SpotifyApi.apiBaseUrl + "me", method: .GET, completion: completion)
    }
    
    func getPlaylist(withId id: String, fields: [String]? = nil, completion: @escaping (Playlist?) -> ()) {
        let url = SpotifyApi.apiBaseUrl + "playlists/\(id)"
        let parameters = ["fields": fields?.joined(separator: ",")]
        _ = makeRequest(url: url, method: .GET, parameters: parameters, completion: completion)
    }
    
    func getPlaylists(offset: Int = 0, limit: Int = 20, completion: @escaping (PagingResponse<Playlist>?) -> ()) {
        let url = SpotifyApi.apiBaseUrl + "me/playlists"
        let parameters = ["offset": offset, "limit": limit]
        _ = makeRequest(url: url, method: .GET, parameters: parameters, completion: completion)
    }
    
    func getPlaylistTracks(playlistId: String, offset: Int = 0, limit: Int = 20,
                           completion: @escaping (PagingResponse<TrackItem>?) -> ()) {
        let url = SpotifyApi.apiBaseUrl + "playlists/\(playlistId)/tracks"
        let parameters = ["offset": offset, "limit": limit]
        _ = makeRequest(url: url, method: .GET, parameters: parameters, completion: completion)
    }
    
    func searchTracks(searchTerm: String, offset: Int = 0, limit: Int = 20,
                      completion: @escaping (SearchResponse?) -> ()) -> Cancellable? {
        let url = SpotifyApi.apiBaseUrl + "search"
        let parameters = ["q": searchTerm, "limit": "\(limit)", "offset": "\(offset)", "type": "track"]
        guard let request = makeRequest(url: url, method: .GET, parameters: parameters, completion: completion) else {
            return nil
        }
        return CancellableRequest(request)
    }
    
    func createPlaylist(name: String, userId: String, completion: @escaping (Playlist?) -> ()) {
        let url = SpotifyApi.apiBaseUrl + "users/\(userId)/playlists"
        _ = makeRequest(url: url, method: .POST, body: ["name": name, "public": false], completion: completion)
    }
    
    func addTracksToPlaylist(withId id: String, uris: [String], completion: @escaping (SnapshotResponse?) -> ()) {
        let url = SpotifyApi.apiBaseUrl + "playlists/\(id)/tracks"
        let parameters = ["uris": uris]
        _ = makeRequest(url: url, method: .POST, body: parameters, completion: completion)
    }
    
    func removeTracksFromPlaylist(withId id: String, uris: [String], completion: @escaping (SnapshotResponse?) -> ()) {
        let url = SpotifyApi.apiBaseUrl + "playlists/\(id)/tracks"
        let tracks = uris.map { ["uri": $0] }
        let parameters = ["tracks": tracks]
        _ = makeRequest(url: url, method: .DELETE, body: parameters, completion: completion)
    }
    
    func reorderTracksInPlaylist(withId id: String, fromIndex: Int, toIndex: Int, completion: @escaping (SnapshotResponse?) -> ()) {
        let url = SpotifyApi.apiBaseUrl + "playlists/\(id)/tracks"
        let parameters = ["range_start": fromIndex, "insert_before": toIndex]
        _ = makeRequest(url: url, method: .PUT, body: parameters, completion: completion)
    }
    
    func updatePlaylistName(withId id: String, name: String, completion: @escaping (Bool?) -> ()) {
        let url = SpotifyApi.apiBaseUrl + "playlists/\(id)"
        let parameters = ["name": name]
        _ = makeNoResponseRequest(url: url, method: .PUT, body: parameters, completion: completion)
    }
    
    
    private func makeNoResponseRequest(
        url: String,
        method: OAuthSwiftHTTPRequest.Method,
        parameters: OAuthSwift.Parameters? = nil,
        body: [String: Any]? = nil,
        headers: [String: String]? = nil,
        completion: @escaping (Bool?) -> ()) -> OAuthSwiftRequestHandle? {
        
        let data = makeData(body: body)
        return oAuth.startAuthorizedRequest(
            url,
            method: method,
            parameters: parameters ?? [:],
            headers: headers,
            body: data,
            success: { response in
                completion(true)
            },
            failure: { error in
                self.handleFailure(error: error)
                completion(nil)
            }
        )
    }
    
    private func makeRequest<T>(
        url: String, method: OAuthSwiftHTTPRequest.Method,
        parameters: OAuthSwift.Parameters? = nil,
        body: [String: Any]? = nil,
        headers: [String: String]? = nil,
        isNoResponse: Bool = false,
        completion: @escaping (T?) -> ()) -> OAuthSwiftRequestHandle? where T: Decodable {
        
        let data = makeData(body: body)
        return oAuth.startAuthorizedRequest(
            url,
            method: method,
            parameters: parameters ?? [:],
            headers: headers,
            body: data,
            success: { response in
                let object = T.decode(data: response.data)
                completion(object)
            },
            failure: { error in
                self.handleFailure(error: error)
                completion(nil)
            }
        )
    }
    
    private func makeData(body: [String: Any]?) -> Data? {
        return body == nil ? nil : try? JSONSerialization.data(withJSONObject: body as Any, options: [])
    }
    
    private func handleFailure(error: OAuthSwiftError) {
        if error.description.contains("Code=401") || error.description.contains("Code=400") {
            self.cache.isUserAuthorized = false
            self.cache.userCredentials = nil
        }
        Logger.log(error)
    }
}
