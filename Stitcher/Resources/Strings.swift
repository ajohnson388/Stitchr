//
//  Strings.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/29/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation

enum Strings: String {
    case playlistsTitle
    case loginRequiredTitle
    case errorTitle
    case playlistsEmptyTitle
    case loginRequiredButtonTitle
    case searchSectionTitle
    case tracksSectionTitle
    case loginRequiredDescription
    case playlistsEmptyDescription
    case errorButtonTitle
    case emptyPlaylistsButtonTitle
    case searchPlaceholder
    case newPlaylistTitle
    case numberOfTracks
    case tracksEmptyTitle
    case tracksEmptyDescription
    case tracksEmptyButtonTitle
    case tracksFooterDescription
    case searchResultsEmptyTitle
    case searchResultsDescription
    case playlistReorderButtonTitle
    case playlistCancelButtonTitle
    case createPlaylistShortcutTitle
    
    var localized: String {
        return NSLocalizedString(rawValue, comment: "")
    }
}
