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
    
    private var headerView: EditTableView?
    private let editButton = UIBarButtonItem(image: Images.editIcon.make(), style: .plain, target: nil, action: nil)
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
        presenter.tracksDataSource.refresh()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = true
        hero.isEnabled = false
        navigationController?.hero.isEnabled = false
    }
    
    override func getEmptyStateConfig() -> EmptyStateConfig? {
        if let config = super.getEmptyStateConfig() {
            return config
        } else if presenter.searchDataSource.items.isEmpty && isSearching {
            var config = EmptyStateConfig()
            let searchText = navigationItem.searchController?.searchBar.text ?? ""
            config.state = .empty
            config.title = (Strings.searchResultsEmptyTitle.localized + "\"\(searchText)\"").attributed
            config.description = Strings.searchResultsDescription.localized.attributed
            return config
        } else if presenter.tracksDataSource.items.isEmpty && !isSearching {
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
        guard presenter.isAuthenticated else {
            return 0
        }
        return isSearching ? presenter.searchDataSource.items.count : presenter.tracksDataSource.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSearching {
            let track = presenter.searchDataSource.items[indexPath.row]
            let occurrences = presenter.tracksDataSource.items.count(where: { $0.track?.uri == track.uri })
            return ViewFactory.makeSearchTableViewCell(tableView, indexPath: indexPath, track: track, occurrences: occurrences)
        } else {
            return ViewFactory.makeTrackTableViewCell(tableView, indexPath: indexPath, track: presenter.tracksDataSource.items[indexPath.row].track)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Load images if needed
        let track = isSearching ? presenter.searchDataSource.items[indexPath.row] : presenter.tracksDataSource.items[indexPath.row].track
        ViewFactory.loadImage(track?.album.images.last?.url, forCell: cell)
        
        // Fetch more items if needed
        if isSearching && indexPath.row == presenter.searchDataSource.items.count - 1 {
            presenter.searchDataSource.loadMoreIfNeeded()
        } else if indexPath.row == presenter.tracksDataSource.items.count - 1 {
            presenter.tracksDataSource.loadMoreIfNeeded()
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        presenter.reorderTrack(fromIndex: sourceIndexPath.row, toIndex: destinationIndexPath.row) { success in
            
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    
    // MARK: - Table Delegate
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return isSearching ? 22 : UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return isSearching && !presenter.searchDataSource.items.isEmpty
            ? Strings.searchSectionTitle.localized
            : nil
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return !isSearching && !presenter.tracksDataSource.items.isEmpty && presenter.searchDataSource.items.isEmpty
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Tracks cannot be selected only search results
        guard !presenter.searchDataSource.items.isEmpty && isSearching else {
            return
        }
        
        // Start the loading indicator for the track
        let cell = tableView.cellForRow(at: indexPath) as? SearchTableViewCell
        cell?.setLoading(true)
        
        // Add the track
        presenter.addTrack(at: indexPath.row) { success in
            cell?.setLoading(false)
            if success {
                tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
    
    
    // MARK: - Button Actions
    
    @objc
    func editButtonTapped() {
        guard let navigationController = navigationController else {
            return
        }
        
        // Configure first controller transition
        hero.isEnabled = true
        navigationController.hero.isEnabled = true
        navigationController.hero.navigationAnimationType = .autoReverse(presenting: .uncover(direction: .down))

        // Configure second controller transition
        let editPlaylistController = EditPlaylistViewController.make()
        let cache = LocalCache()
        let spotifyApi = SpotifyApi(cache: cache)
        let editPresenter = EditPlaylistPresenter(cache: cache, spotifyApi: spotifyApi)
        editPresenter.editPlaylistDelegate = editPlaylistController
        editPresenter.playlist = presenter.playlist
        editPlaylistController.presenter = editPresenter
        editPlaylistController.delegate = self

        
        // Show the edit controller
        navigationController.pushViewController(editPlaylistController, animated: true)
    }
    
    
    // MARK: - Helper Functions
    
    private func setupView() {
        // Setup the nav bar
        editButton.target = self
        editButton.action = #selector(editButtonTapped)
        navigationItem.rightBarButtonItem = editButton
        navigationItem.title = presenter.playlist?.name ?? Strings.newPlaylistTitle.localized
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Setup search
        let searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = Strings.searchPlaceholder.localized
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // Setup tableview
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
    }
    
    private var isReorderControlHidden: Bool {
        get {
            guard let view = tableView.tableHeaderView else {
                return false
            }
            return view.isHidden
        }
        set {
            let oldValue = isReorderControlHidden
            guard !newValue else {
                tableView.tableHeaderView?.isHidden = true
                tableView.setEditing(false, animated: true)
                if !oldValue {
                    headerView?.editButtonView.setTitle(Strings.playlistReorderButtonTitle.localized, for: .normal)
                }
                return
            }
            guard let view = tableView.tableHeaderView else {
                let view = EditTableView(width: tableView.frame.width)
                view.delegate = self
                tableView.tableHeaderView = view
                headerView = view
                return
            }
            view.isHidden = false
            
        }
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
            presenter.tracksDataSource.refresh()
            break
        case .empty:
            navigationItem.searchController?.searchBar.becomeFirstResponder()
        default:
            return
        }
    }
    
    
    // MARK: - Search Delegate
    
    func updateSearchResults(for searchController: UISearchController) {
        presenter.search(searchController.searchBar.text ?? "")
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        tableView.reloadData()
        isReorderControlHidden = presenter.tracksDataSource.items.count == 0
    }
    
    
    // MARK: - Base Presenter Delegate
    
    override func isUserAuthenticatedDidChange(_ isAuthenticated: Bool) {
        isAuthenticated ? presenter.tracksDataSource.refresh() : tableView.reloadData()
    }
    
    override func isLoadingChanged(_ isLoading: Bool) {
        if (presenter.tracksDataSource.items.isEmpty || presenter.searchDataSource.items.isEmpty) && isLoading {
            tableView.reloadData()
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
        
        isReorderControlHidden = tracks.count == 0 || isSearching
    }
    
    func searchResultsDidChange(_ tracks: [Track]) {
        isReorderControlHidden = true
        tableView.reloadData()
    }
}


// MARK: - Edit Playlist Delegate

extension PlaylistViewController: EditPlaylistViewControllerDelegate {
    
    func playlistTitleDidChange(title: String) {
        navigationItem.title = title
    }
}


// MARK: - Edit Table Delegate

extension PlaylistViewController: EditTableViewDelegate {
    
    func onEditButtonTapped(button: UIButton) {
        // Animate the title change based on the table view editing state
        let title = tableView.isEditing ? Strings.playlistReorderButtonTitle.localized : Strings.playlistCancelButtonTitle.localized
        UIView.transition(with: button, duration: 0.2, options: .transitionCrossDissolve, animations: {
            button.setTitle(title, for: .normal)
        }, completion: { _ in
            self.tableView.setEditing(!self.tableView.isEditing, animated: true)
        })
    }
}
