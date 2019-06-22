//
//  PlaylistsViewController.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/23/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import DZNEmptyDataSet

final class PlaylistsViewController: BaseTableViewController<PlaylistsPresenter>, UIViewControllerPreviewingDelegate {
    
    // MARK: - Properties
    
    private let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
    
    var newPlaylistDiscoverabilityTitle =  "New Playlist"
    
    override var keyCommands: [UIKeyCommand]? {
        get {
            var commands = super.keyCommands ?? []
            
            commands.append(UIKeyCommand(input: "N", modifierFlags: [UIKeyModifierFlags.command], action: #selector(newPlaylistTriggered), discoverabilityTitle: newPlaylistDiscoverabilityTitle))
            return commands
        }
    }
    
    // MARK: - Lifecycle
    
    override init(presenter: PlaylistsPresenter) {
        super.init(presenter: presenter)
        presenter.playlistsDelegate = self
        
        childView.selectAboveDiscoverabilityTitle = "Select Playlist Above"
        childView.selectBelowDiscoverabilityTitle = "Select Playlist Below"
        childView.selectTopDiscoverabilityTitle = "Select First Playlist"
        childView.selectBottomDiscoverabilityTitle = "Select Last Playlist"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if presenter.isAuthenticated {
            presenter.playlistsDataSource.refresh()
        }
    }
    
    override func getEmptyStateConfig() -> EmptyStateConfig? {
        if let config = super.getEmptyStateConfig() {
            return config
        } else if presenter.playlistsDataSource.items.isEmpty {
            var config = EmptyStateConfig()
            config.state = .empty
            config.title = Strings.playlistsEmptyTitle.localized.attributed
            config.description = Strings.playlistsEmptyDescription.localized.attributed
            config.buttonTitle = Strings.emptyPlaylistsButtonTitle.localized.attributed
            return config
        } else {
            return nil
        }
    }
    
    
    // MARK: - Event Callbacks
    
    @objc
    private func addButtonTapped(_ button: UIBarButtonItem) {
        openPlaylist(playlist: nil)
    }
    
    @objc func newPlaylistTriggered() {
        openPlaylist(playlist: nil)
    }
    
    @objc
    private func didRefreshTable(_ refreshControl: UIRefreshControl) {
        presenter.playlistsDataSource.refresh()
    }
    
    
    // MARK: - Table Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.playlistsDataSource.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let playlist = presenter.playlistsDataSource.items[indexPath.row]
        return ViewFactory.makePlaylistTableViewCell(tableView, indexPath: indexPath, playlist: playlist)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        ViewFactory.loadImage(presenter.playlistsDataSource.items[indexPath.row].images.last?.url, forCell: cell)
        if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            presenter.playlistsDataSource.loadMoreIfNeeded()
        }
    }
    
    
    // MARK: - Table Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Navigate to the playlist
        let playlist = presenter.playlistsDataSource.items[indexPath.row]
        openPlaylist(playlist: playlist)
    }
    
    
    // MARK: - Setup Functions
    
    private func setupView() {
        setupAddButton()
        setupNavBar()
        setupLogoImage()
        setupTableView()
        setupPeekAndPop()
    }
    
    private func setupPeekAndPop() {
        // Assert 3D touch is available
        guard traitCollection.forceTouchCapability == .available else {
            return
        }
        registerForPreviewing(with: self, sourceView: view)
    }
    
    private func setupAddButton() {
        // Configure the button
        addButton.target = self
        addButton.action = #selector(addButtonTapped)
        if !presenter.isAuthenticated {
            addButton.isEnabled = false
        }
        
        // Add the button
        navigationItem.rightBarButtonItem = addButton
    }
    
    private func setupNavBar() {
        navigationItem.title = Strings.playlistsTitle.localized
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupTableView() {
        // Add the refresh control
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(didRefreshTable), for: .valueChanged)
        
        // Configure for empty data sets
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
    }
    
    private func setupLogoImage() {
        // Create the custom image view
        let logoImageView = UIImageView(image: Images.stitcherLogo.make())
        logoImageView.frame = CGRect(x: 0,y: 0, width:60, height: 25)
        logoImageView.contentMode = .scaleAspectFit
        
        // Configure the logo constraints
        let imageItem = UIBarButtonItem(customView: logoImageView)
        let widthConstraint = logoImageView.widthAnchor.constraint(equalToConstant: 60)
        let heightConstraint = logoImageView.heightAnchor.constraint(equalToConstant: 25)
        heightConstraint.isActive = true
        widthConstraint.isActive = true
        
        // Add the logo
        imageItem.isEnabled = false
        navigationItem.leftBarButtonItem =  imageItem
    }
    
    
    // MARK: - Helper Functions
    
    private func makePlaylistViewController(playlist: Playlist?) -> PlaylistViewController {
        let cache = LocalCache()
        let spotifyApi = SpotifyApi(cache: cache)
        let playlistPresenter = PlaylistPresenter(cache: cache, spotifyApi: spotifyApi)
        cache.delegate = playlistPresenter
        playlistPresenter.setPlaylist(playlist: playlist)
        return PlaylistViewController(presenter: playlistPresenter)
    }
    
    func openPlaylist(playlist: Playlist?, animated: Bool = true) {
        let playlistViewController = makePlaylistViewController(playlist: playlist)
        navigationController?.pushViewController(playlistViewController, animated: animated)
    }
    
    
    // MARK: - Base Presenter Delegate
    
    override func isUserAuthenticatedDidChange(_ isAuthenticated: Bool) {
        addButton.isEnabled = true
        isAuthenticated ? presenter.playlistsDataSource.refresh() : tableView.reloadEmptyDataSet()
    }
    
    override func isLoadingChanged(_ isLoading: Bool) {
        if presenter.playlistsDataSource.items.isEmpty && isLoading {
            tableView.reloadEmptyDataSet()
        }
    }
    
    
    // MARK: - Empty State Delegate
    
    override func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        guard let state = getEmptyStateConfig()?.state else {
            return
        }
        
        switch state {
        case .authenticationChallenge:
            presenter.login()
        case .error:
            presenter.playlistsDataSource.refresh()
        case .empty:
            openPlaylist(playlist: nil)
        default:
            return
        }
    }
    
    
    // MARK: - Peek and Pop
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else {
            return nil
        }
        previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
        
        let playlist = presenter.playlistsDataSource.items[indexPath.row]
        return makePlaylistViewController(playlist: playlist)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}


// MARK: - Presenter Delegate

extension PlaylistsViewController: PlaylistsPresenterDelegate {
    
    func playlistsDidChange(_ playlists: [Playlist]) {
        tableView.refreshControl?.endRefreshing()
        
        // Animate on first load
        if tableView.numberOfRows(inSection: 0) == 0 {
            tableView.beginUpdates()
            tableView.reloadSections(IndexSet(integer: 0), with: .fade)
            tableView.endUpdates()
        } else {
            tableView.reloadData()
        }
    }
    
    func newPlaylistDidChange(_ playlist: Playlist?) {
        addButton.isEnabled = true
        if let playlist = playlist {
            openPlaylist(playlist: playlist)
        }
    }
}
