//
//  ViewFactory.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/26/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import UIKit
import Anchorage
import SDWebImage

struct ViewFactory {
    
    static func makePlaylistTableViewCell(_ tableView: UITableView, indexPath: IndexPath, playlist: Playlist) -> UITableViewCell {
        let reuseId = "playlistCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: reuseId)
        cell.textLabel?.text = playlist.name
        cell.detailTextLabel?.text = "\(playlist.tracks.total)" + Strings.numberOfTracks.localized
        cell.imageView?.image = Images.imagePlaceholder.make()
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    static func makeTrackTableViewCell(_ tableView: UITableView, indexPath: IndexPath, track: Track?) -> UITableViewCell {
        let reuseId = "trackCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: reuseId)
        cell.textLabel?.text = track?.name
        cell.detailTextLabel?.text = [track?.artists.first?.name, track?.album.name].compactMap({ $0 }).joined(separator: " • ")
        cell.imageView?.image = Images.imagePlaceholder.make()
        cell.selectionStyle = .none
        return cell
    }
    
    static func makeSearchTableViewCell(_ tableView: UITableView, indexPath: IndexPath, track: Track?, occurrences: Int)
        -> UITableViewCell {
        let reuseId = "searchCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId) as? SearchTableViewCell
            ?? SearchTableViewCell(reuseIdentifier: reuseId)
        cell.textLabel?.text = track?.name
        cell.detailTextLabel?.text = [track?.artists.first?.name, track?.album.name].compactMap({ $0 }).joined(separator: " • ")
        cell.imageView?.image = Images.imagePlaceholder.make()
        cell.selectionStyle = .gray
        cell.setOccurrences(occurrences)
        return cell
    }
    
    static func loadImage(_ imageUrlString: String?, forCell cell: UITableViewCell) {
        let imageUrl = imageUrlString == nil ? nil : try? imageUrlString!.asURL()
        cell.imageView?.sd_setImage(with: imageUrl, placeholderImage: Images.imagePlaceholder.make(),
                                    options: [SDWebImageOptions.progressiveDownload, SDWebImageOptions.continueInBackground])
    }
}
