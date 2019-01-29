//
//  PlaylistViewController.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/25/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

/**
    The user interface for adding, re-ordering, and remove tacks in a playlist.
 */
final class PlaylistViewController: UITableViewController {
    
    // MARK: - Properties
    
    private let presenter: PlaylistPresenter
    
    private var isSearching: Bool {
        let isSearchTextEmpty = navigationItem.searchController?.searchBar.text?.isEmpty ?? true
        let isSearchActive = navigationItem.searchController?.isActive ?? false
        return isSearchActive && !isSearchTextEmpty
    }
    
    
    // MARK: - Lifecycle
    
    init(presenter: PlaylistPresenter) {
        self.presenter = presenter
        super.init(style: .grouped)
        presenter.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        presenter.loadTracks()
    }
    
    
    // MARK: - Table Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return isSearching && presenter.searchResults.count > 0 ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching && section == 0 ? presenter.searchResults.count : presenter.tracks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSearching && indexPath.section == 0 {
            let track = presenter.searchResults[indexPath.row]
            let occurrences = presenter.tracks.count(where: { $0.track?.uri == track.uri })
            return ViewFactory.makeSearchTableViewCell(tableView, indexPath: indexPath, track: track, occurrences: occurrences)
        } else {
            return ViewFactory.makeTrackTableViewCell(tableView, indexPath: indexPath, track: presenter.tracks[indexPath.row].track)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let track = isSearching && indexPath.section == 0 ? presenter.searchResults[indexPath.row]
            : presenter.tracks[indexPath.row].track
        ViewFactory.loadImage(track?.album.images.last?.url, forCell: cell)
    }
    
    
    // MARK: - Table Delegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 && isSearching
            ? Strings.searchSectionTitle.localized
            : Strings.tracksSectionTitle.localized
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let isAdding = indexPath.section == 0 && isSearching
        let action = UIContextualAction(style: isAdding ? .normal : .destructive, title: nil) { action, sourceView, completionHandler in
            isAdding ? self.presenter.addTrack(at: indexPath.row, completion: completionHandler)
                : self.presenter.removeTrack(at: indexPath.row, completion: completionHandler)
        }
        action.image = indexPath.section == 0 && isSearching ? Images.add.make() : Images.delete.make()
        action.backgroundColor = Themes.current.secondaryLightColor
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    
    // MARK: - Helper Functions
    
    private func setupView() {
        navigationItem.title = presenter.playlist?.name ?? Strings.newPlaylistTitle.localized
        let searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = Strings.searchPlaceholder.localized
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
}


// MARK: - Presenter Delegate

extension PlaylistViewController: PlaylistPresenterDelegate {
    
    func tracksDidChange(_ tracks: [TrackItem]) {
        tableView.reloadData()
    }
    
    func searchResultsDidChange(_ tracks: [Track]) {
        tableView.reloadData()
    }
}


// MARK: - Search Controller Delegate

extension PlaylistViewController: UISearchControllerDelegate, UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        presenter.search(text: searchController.searchBar.text ?? "")
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        tableView.reloadData()
    }
}
