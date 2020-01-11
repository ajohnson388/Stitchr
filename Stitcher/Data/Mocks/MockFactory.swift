//
//  MockFactory.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/2/20.
//  Copyright © 2020 Meaningless. All rights reserved.
//

import Foundation

class MockFactory {
    
    static let shared = MockFactory()
    
    private init() {}
    
    var userProfile: UserProfile {
        return UserProfile(id: "test+spotify@gmail.com", displayName: "Test Account")
    }
    
    var externalUrls: ExternalUrls {
        return ExternalUrls(spotify: "https://www.spotify.com")
    }
    
    var externalIds: ExternalIDS {
        return ExternalIDS(isrc: "1234567890")
    }
    
    var owner: Owner {
        return Owner(externalUrls: externalUrls, href: "https://www.spotify.com",
                     id: userProfile.id ?? "", type: "Owner", uri: "1234567890")
    }
    
    var addedBy: AddedBy {
        return AddedBy(externalUrls: externalUrls, href: "https://google.com",
                       id: userProfile.id ?? "", type: "Artist", uri: "1234567890",
                       name: "Art the Artist")
    }
    
    var album: Album {
        return Album(albumType: "EP", artists: [addedBy], availableMarkets: ["US"],
                     externalUrls: externalUrls, href: "https://google.com", id: "SomeAlbum",
                     images: [], name: "Art's Album", type: "Album", uri: "1234567890")
    }
    
    func track(id: String, name: String, trackNumber: Int) -> Track {
        return Track(album: album, artists: [addedBy], availableMarkets: ["US"], discNumber: 1,
                     durationMs: 50000, explicit: false, externalIds: externalIds, externalUrls: externalUrls,
                     href: "https://google.com", id: id, name: name, popularity: 4, previewUrl: nil,
                     trackNumber: trackNumber, type: "track", uri: "1234567890")
    }
    
    func tracks(amount: Int) -> [Track] {
        return (0..<amount).map {
            return track(id: "\($0)", name: "Playlist \($0)", trackNumber: $0 + 1)
        }
    }
    
    func trackItems(amount: Int) -> [TrackItem] {
        return tracks(amount: amount).map {
            return TrackItem(addedAt: Date(), addedBy: addedBy, isLocal: false, track: $0)
        }
    }
    
    func playlist(id: String, name: String, totalTracks: Int) -> Playlist {
        let tracks = Tracks(href: nil, total: totalTracks)
        return Playlist(collaborative: false, externalUrls: externalUrls, href: nil, id: id,
                        images: [], name: name, owner: owner, itemPublic: nil, snapshotID: nil,
                        tracks: tracks, type: "playlist", uri: "1234567890")
    }
    
    func playlists(amount: Int) -> [Playlist] {
        return (0..<amount).map {
            return playlist(id: "\($0)", name: "Playlist \($0)", totalTracks: 1)
        }
    }
}
