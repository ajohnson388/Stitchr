//
//  UITableView+Convenience.swift
//  Stitcher
//
//  Created by Andrew Johnson on 7/14/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    
    var isEmpty: Bool {
        for i in 0..<numberOfSections {
            if numberOfRows(inSection: i) > 0 {
                return false
            }
        }
        return true
    }
    
    func singleSelect(at indexPath: IndexPath) {
        for path in indexPathsForSelectedRows ?? [] where indexPath != path {
            deselectRow(at: indexPath, animated: false)
        }
    }
    
    func makePlaylistCell(_ playlist: Playlist) -> UITableViewCell {
        let reuseId = "playlistCell"
        let cell = dequeueReusableCell(withIdentifier: reuseId) as? FixedImageTableViewCell
            ?? FixedImageTableViewCell(style: .subtitle, reuseIdentifier: reuseId)
        cell.accessoryType = .disclosureIndicator
        cell.titleLabel.text = playlist.name
        cell.detailLabel.text = "\(playlist.tracks.total)" + Strings.numberOfTracks.localized
        cell.setImage(urlString: playlist.images.last?.url)
        return cell
    }
    
    func makeTrackCell(_ track: Track?) -> UITableViewCell {
        let reuseId = "trackCell"
        let cell = dequeueReusableCell(withIdentifier: reuseId) as? FixedImageTableViewCell
            ?? FixedImageTableViewCell(style: .subtitle, reuseIdentifier: reuseId)
        cell.selectionStyle = .none
        cell.titleLabel.text = track?.name
        cell.detailLabel.text = track?.sourceDescription
        cell.setImage(urlString: track?.album.images.last?.url)
        return cell
    }
    
    func makeSearchCell(track: Track?, occurrences: Int)
        -> UITableViewCell {
        let reuseId = "searchCell"
        let cell = dequeueReusableCell(withIdentifier: reuseId) as? SearchTableViewCell
            ?? SearchTableViewCell(reuseIdentifier: reuseId)
        cell.selectionStyle = .gray
        cell.titleLabel.text = track?.name
        cell.detailLabel.text = track?.sourceDescription
        cell.setOccurrences(occurrences)
        cell.setImage(urlString: track?.album.images.last?.url)
        return cell
    }
}
