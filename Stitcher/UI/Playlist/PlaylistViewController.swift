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
import DZNEmptyDataSet

/**
    The user interface for adding, re-ordering, and remove tacks in a playlist.
 */
final class PlaylistViewController: BaseTableViewController<PlaylistPresenter>, UISearchControllerDelegate, UISearchResultsUpdating {
    
    // MARK: - Properties
    
    private var isSearching: Bool {
        let isSearchTextEmpty = navigationItem.searchController?.searchBar.text?.isEmpty ?? true
        let isSearchActive = navigationItem.searchController?.isActive ?? false
        return isSearchActive && !isSearchTextEmpty
    }
    
    
    // MARK: - Lifecycle
    
    override init(presenter: PlaylistPresenter) {
        super.init(presenter: presenter)
        presenter.playlistDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        presenter.loadTracks()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    override func getEmptyStateConfig() -> EmptyStateConfig? {
        if let config = super.getEmptyStateConfig() {
            return config
        } else if presenter.searchResults.isEmpty && isSearching {
            var config = EmptyStateConfig()
            let searchText = navigationItem.searchController?.searchBar.text ?? ""
            config.state = .empty
            config.title = (Strings.searchResultsEmptyTitle.localized + "\"\(searchText)\"").attributed
            config.description = Strings.searchResultsDescription.localized.attributed
            return config
        } else if presenter.tracks.isEmpty && !isSearching {
            var config = EmptyStateConfig()
            config.state = .empty
            config.buttonTitle = Strings.tracksEmptyButtonTitle.localized.attributed
            config.description = Strings.tracksEmptyDescription.localized.attributed
            config.title = Strings.tracksEmptyTitle.localized.attributed
            return config
        } else {
            return nil
        }
    }
    
    
    // MARK: - Table Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? presenter.searchResults.count : presenter.tracks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSearching {
            let track = presenter.searchResults[indexPath.row]
            let occurrences = presenter.tracks.count(where: { $0.track?.uri == track.uri })
            return ViewFactory.makeSearchTableViewCell(tableView, indexPath: indexPath, track: track, occurrences: occurrences)
        } else {
            return ViewFactory.makeTrackTableViewCell(tableView, indexPath: indexPath, track: presenter.tracks[indexPath.row].track)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let track = isSearching ? presenter.searchResults[indexPath.row] : presenter.tracks[indexPath.row].track
        ViewFactory.loadImage(track?.album.images.last?.url, forCell: cell)
    }
    
    
    // MARK: - Table Delegate
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return isSearching ? 22 : UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return isSearching && !presenter.searchResults.isEmpty
            ? Strings.searchSectionTitle.localized
            : nil
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return !isSearching && !presenter.tracks.isEmpty && presenter.searchResults.isEmpty
            ? Strings.tracksFooterDescription.localized
            : nil
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: isSearching ? .normal : .destructive, title: nil) {
            action, sourceView, completionHandler in
            
            self.isSearching
                ? self.presenter.addTrack(at: indexPath.row, completion: completionHandler)
                : self.presenter.removeTrack(at: indexPath.row, completion: completionHandler)
        }
        action.image = isSearching ? Images.add.make() : Images.delete.make()
        action.backgroundColor = Themes.current.secondaryLightColor
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
    
    
    // MARK: - Helper Functions
    
    private func setupView() {
        navigationItem.title = presenter.playlist?.name ?? Strings.newPlaylistTitle.localized
        navigationItem.hidesSearchBarWhenScrolling = false
        let searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = Strings.searchPlaceholder.localized
        navigationItem.searchController = searchController
        definesPresentationContext = true
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
    }
    
    
    // MARK: - Empty State Delegate
    
    override func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        guard let state = getEmptyStateConfig()?.state else {
            return
        }
        
        switch state {
        case .authenticationChallenge:
            presenter.login(viewController: self)
        case .error:
            presenter.loadTracks()
            break
        case .empty:
            navigationItem.searchController?.searchBar.becomeFirstResponder()
        default:
            return
        }
    }
    
    
    // MARK: - Search Delegate
    
    func updateSearchResults(for searchController: UISearchController) {
        presenter.search(text: searchController.searchBar.text ?? "")
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        tableView.reloadData()
    }
    
    
    // MARK: - Base Presenter Delegate
    
    override func isUserAuthenticatedDidChange(_ isAuthenticated: Bool) {
        isAuthenticated ? presenter.loadTracks() : tableView.reloadEmptyDataSet()
    }
    
    override func isLoadingChanged(_ isLoading: Bool) {
        if (presenter.tracks.isEmpty || presenter.searchResults.isEmpty) && isLoading {
            tableView.reloadEmptyDataSet()
        }
    }
}


// MARK: - Presenter Delegate

extension PlaylistViewController: PlaylistPresenterDelegate {
    
    func tracksDidChange(_ tracks: [TrackItem]) {
        if tableView.numberOfRows(inSection: 0) == 0 {
            tableView.beginUpdates()
            tableView.reloadSections(IndexSet(integer: 0), with: .fade)
            tableView.endUpdates()
        } else {
            tableView.reloadData()
        }
    }
    
    func searchResultsDidChange(_ tracks: [Track]) {
        tableView.reloadData()
    }
}
