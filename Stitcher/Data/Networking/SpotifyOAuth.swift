//
//  SpotifyOAuth.swift
//  Stitcher
//
//  Created by Andrew Johnson on 3/1/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import Alamofire
import SafariServices

protocol SpotifyOAuthDelegate: class {
    func didAuthorizeSpoitfy(_ isAuthorized: Bool)
}

/// An implementation of the Spotify single sign on flow.
final class SpotifyOAuth {
    
    // MARK: - Properties
    
    weak var delegate: SpotifyOAuthDelegate?
    
    /// The base url for the Spotify accounts API.
    static let accountsBaseUrl = "https://accounts.spotify.com/"
    
    /// The callback url for Spotify SSO.
    static let redirectUri = "com.andyjohnson.stitchr://oauth"
    
    /// The permissions required for the app to function.
    static let permissionScopes = [
        "playlist-read-private",
        "playlist-modify-private",
        "playlist-modify-public",
        "playlist-read-collaborative",
        "user-read-birthdate",
        "user-read-email",
        "user-read-private"
    ]
    
    private let cache: Cache
    private var session: SFAuthenticationSession?
    private var credentials: TokenStore? = LocalCache().userCredentials {
        didSet {
            cache.userCredentials = credentials
        }
    }
    
    
    // MARK: - Lifecycle
    
    
    /// Instantiates a wrapper for the Spotify SSO flow.
    ///
    /// - Parameter cache: The local cache for restoring user credentials.
    init(cache: Cache) {
        self.cache = cache
    }
    
    
    // MARK: - Public Functions
    
    /// Makes a request to authorize Spotify for SSO.
    func authorizeSpotify() {
        session = makeAuthSession()
        session?.start()
    }
    
    /// Makes an authorized request for json data.
    ///
    /// - Parameters:
    ///   - url: The url to request.
    ///   - method: The method of the HTTP request.
    ///   - parameters: The parameters to use in the request body.
    ///   - encoding: The encoding to use for the parameters.
    ///   - headers: The headers for the HTTP request.
    ///   - completion: A callback that returns the result, or nil, if an error occurred.
    /// - Returns: Returns a cancellable request, or nil, if the request could not be constructed.
    func makeJsonRequest<T>(url: URL, method: HTTPMethod,
                            parameters: Parameters? = nil,
                            encoding: ParameterEncoding = JSONEncoding(),
                            headers: [String: String]? = nil,
                            completion: @escaping (T?) -> ()) -> Cancellable? where T: Codable {
        // Wrap the header with the auth token or fail if the token is missing
        guard let authorizedHeaders = addAuthHeader(to: headers) else {
            Logger.log(#function, "Authorization headers are missing.")
            completion(nil)
            return nil
        }
        
        let newRequest = request(url, method: method, parameters: parameters, encoding: encoding, headers: authorizedHeaders).responseJSON { jsonResponse in
            // Assert there is a response
            guard let response = jsonResponse.response else {
                Logger.log(#function, "Response is missing for url: \(url.absoluteString)")
                completion(nil)
                return
            }
            
            // Take action based on the returned status code
            switch response.statusCode {
            case 401:
                // Check if the token needs to be refreshed
                self.refreshToken { success in
                    guard success else {
                        completion(nil)
                        return
                    }
                    _ = self.makeJsonRequest(url: url, method: method, encoding: encoding, completion: completion)
                }
            case 0..<400:
                completion(T.decode(data: jsonResponse.data))
            default:
                Logger.log(#function, "Bad status code: \(response.statusCode).")
                self.logStatusCodeError(data: jsonResponse.data)
                completion(nil)
            }
            
        }
        
        // Start and return the cancellable request
        newRequest.resume()
        return CancellableAlamofireRequest(newRequest)
    }
    
    /// Makes an authorized request for an empty response.
    ///
    /// - Parameters:
    ///   - url: The url to request.
    ///   - method: The method of the HTTP request.
    ///   - parameters: The parameters to use in the request body.
    ///   - encoding: The encoding to use for the parameters.
    ///   - headers: The headers for the HTTP request.
    ///   - completion: A callback that returns the true if successful, or nil, if an error occurred.
    /// - Returns: Returns a cancellable request, or nil, if the request could not be constructed.
    func makeVoidRequest(url: URL, method: HTTPMethod,
                         parameters: Parameters? = nil,
                         encoding: ParameterEncoding = JSONEncoding(),
                         headers: [String: String]? = nil,
                         completion: @escaping (Bool) -> ()) -> Cancellable? {
        // Wrap the header with the auth token or fail if the token is missing
        guard let authorizedHeaders = addAuthHeader(to: headers) else {
            Logger.log(#function, "Authorization headers are missing.")
            completion(false)
            return nil
        }
        
        let newRequest = request(url, method: method, parameters: parameters, encoding: encoding, headers: authorizedHeaders).response { dataResponse in
            // Assert there is a response
            guard let response = dataResponse.response else {
                completion(false)
                return
            }
            
            // Check if the access token needs to be renewed
            guard response.statusCode != 401 else {
                Logger.log(#function, "Token refresh initiated.")
                _ = self.renewAccessToken { success in
                    guard success else {
                        Logger.log(#function, "Token refresh failed. Authorization required.")
                        completion(false)
                        return
                    }
                    
                }
                return
            }
            completion(response.statusCode < 400)
            
            // Take action based on the returned status code
            switch response.statusCode {
            case 401:
                // Check if the token needs to be refreshed
                self.refreshToken { success in
                    guard success else {
                        completion(false)
                        return
                    }
                    _ = self.makeVoidRequest(url: url, method: method, encoding: encoding, completion: completion)
                }
            case 0..<400:
                completion(true)
            default:
                Logger.log(#function, "Bad status code: \(response.statusCode).")
                self.logStatusCodeError(data: dataResponse.data)
                completion(false)
            }
        }
        
        // Start and return the cancellable request
        newRequest.resume()
        return CancellableAlamofireRequest(newRequest)
    }

    
    // MARK: - Private Functions
    
    private func logStatusCodeError(data: Data?) {
        guard let data = data else {
            Logger.log(#function, "There is no data to log.")
            return
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            Logger.log(json as Any)
        } catch {
            Logger.log(#function, "Failed to parse json with data: \(data)")
        }
    }
    
    private func addAuthHeader(to header: [String: String]?) -> [String: String]? {
        // Assert the access token exists
        guard let accessToken = credentials?.accessToken else {
            // Trigger authentication if the token is missing
            saveCredentials(nil)
            return nil
        }
        
        var headers = header ?? [:]
        headers["Authorization"] = "Bearer " + accessToken
        return headers
    }
    
    private func onSpotifyAuthorized(url: URL?, error: Error?) {
        guard let code = url?.query?.split(separator: "=").last else {
            return
        }
        _ = requestAccessToken(code: String(code))
    }

    private func requestAccessToken(code: String) -> Cancellable {
        let parameters = [
            "code": code,
            "client_id": BuildConfig.spotifyClientId,
            "client_secret": BuildConfig.spotifyClientSecret,
            "grant_type": "authorization_code",
            "redirect_uri":  SpotifyOAuth.redirectUri
        ]
        let tokenRequest = request(makeUrl(), method: .post, parameters: parameters, encoding: URLEncoding()).responseJSON { response in
            // Decode the token reponse, if it fails, clear the credentials to trigger authorization
            guard let tokenResponse = TokenResponse.decode(data: response.data) else {
                self.delegate?.didAuthorizeSpoitfy(false)
                self.saveCredentials(nil)
                return
            }
            
            // Store credentials and keep in memory
            let tokenStore = TokenStore(tokenResponse: tokenResponse)
            self.saveCredentials(tokenStore)
            self.delegate?.didAuthorizeSpoitfy(true)
        }
        tokenRequest.resume()
        return CancellableAlamofireRequest(tokenRequest)
    }
    
    private func renewAccessToken(completion: @escaping (Bool) -> ()) -> Cancellable? {
        // Assert the refresh token exists, if not, trigger authorization
        guard let refreshToken = credentials?.refreshToken else {
            Logger.log("Error missing refresh token.")
            cache.userCredentials = nil
            completion(false)
            return nil
        }
        
        let parameters = [
            "refresh_token": refreshToken,
            "client_id": BuildConfig.spotifyClientId,
            "client_secret": BuildConfig.spotifyClientSecret,
            "grant_type": "refresh_token"
        ]
        let tokenRequest = request(makeUrl(), method: .post, parameters: parameters, encoding: URLEncoding()).responseJSON { jsonResponse in
            // Decode the token response
            guard let tokenResponse = TokenResponse.decode(data: jsonResponse.data) else {
                self.saveCredentials(nil)
                completion(false)
                return
            }
            
            // Store credentials and keep in memory
            let tokenStore = TokenStore(tokenResponse: tokenResponse)
            self.saveCredentials(tokenStore)
            completion(true)
        }
        tokenRequest.resume()
        return CancellableAlamofireRequest(tokenRequest)
    }
    
    private func saveCredentials(_ credentials: TokenStore?) {
        self.credentials = credentials
        self.cache.userCredentials = credentials
    }
    
    private func parseTokenResponse(url: URL) -> TokenResponse? {
        guard let pairs = url.query?.split(separator: "&") else {
            return nil
        }
        var parameters = [Substring: Substring]()
        for pair in pairs {
            let parts = pair.split(separator: "=")
            guard parts.count == 2 else {
                continue
            }
            parameters[parts[0]] = parts[1]
        }
        
        let data = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        return TokenResponse.decode(data: data)
    }
    
    private func refreshToken(completion: @escaping (Bool) -> ()) {
        Logger.log(#function, "Token refresh initiated.")
        _ = self.renewAccessToken { success in
            guard success else {
                Logger.log(#function, "Token refresh failed. Authorization required.")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    private func makeQueryString(fromParameters parameters: [String: String]) -> String {
        guard parameters.count > 0 else {
            return ""
        }
        let pairs = parameters.map { $0 + "=" + $1 }
        let queryString = "?" + pairs.joined(separator: "&")
        return queryString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
    
    private func makeUrl(endpoint: String = "api/token", withQueryParameters parameters: [String: String] = [:]) -> URL {
        let urlString = SpotifyOAuth.accountsBaseUrl +  endpoint + makeQueryString(fromParameters: parameters)
        return URL(string: urlString)!
    }
    
    private func makeAuthSession() -> SFAuthenticationSession {
        let parameters = [
            "client_id": BuildConfig.spotifyClientId,
            "response_type": "code",
            "redirect_uri": SpotifyOAuth.redirectUri,
            "scope": SpotifyOAuth.permissionScopes.joined(separator: " ")
        ]
        let scheme = "com.andyjohnson.stitchr://"
        let url = makeUrl(endpoint: "authorize", withQueryParameters: parameters)
        let session = SFAuthenticationSession(url: url, callbackURLScheme: scheme, completionHandler: onSpotifyAuthorized)
        return session
    }
}
