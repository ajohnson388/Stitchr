//
//  PlaylistsViewController.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/23/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import UIKit

protocol PlaylistsViewControllerObserver: class {
    func didSelectPlaylist(_ playlist: Playlist?)
    func didCreateNewPlaylist()
    func didDeletePlaylist()
}

final class PlaylistsViewController: BaseTableViewController<PlaylistsPresenter>, UIViewControllerPreviewingDelegate {
    
    // MARK: - Properties
    
    static func make() -> PlaylistsViewController {
        let cache = LocalCache()
        let api = SpotifyApi(cache: cache)
        let presenter = PlaylistsPresenter(cache: cache, api: api)
        cache.delegate = presenter
        return PlaylistsViewController(presenter: presenter)
    }
    
    private let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
    
    var playlistsRouter: PlaylistsViewControllerRouter? = nil
    
    
    // MARK: - Lifecycle
    
    override init(presenter: PlaylistsPresenter) {
        super.init(presenter: presenter)
        presenter.playlistsDelegate = self
        playlistsRouter = PlaylistsRouter(viewController: self)
    }
    
    convenience init(presenter: PlaylistsPresenter, playlistsRouter: PlaylistsViewControllerRouter) {
        self.init(presenter: presenter)
        self.playlistsRouter = playlistsRouter
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        Theme.apply(navigationItem: navigationItem)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if presenter.isAuthenticated {
            presenter.playlistsDataSource.refresh()
        } else {
            reloadTable()
        }
    }
    
    override func getEmptyStateConfig() -> EmptyStateConfig? {
        if let config = super.getEmptyStateConfig() {
            return config
        } else if presenter.playlistsDataSource.items.isEmpty {
            var config = EmptyStateConfig.makeEmpty()
            config.title = Strings.playlistsEmptyTitle.localized
            config.description = Strings.playlistsEmptyDescription.localized
            config.buttonTitle = Strings.emptyPlaylistsButtonTitle.localized
            return config
        } else {
            return nil
        }
    }
    
    
    // MARK: - Event Callbacks
    
    @objc
    private func addButtonTapped(_ button: UIBarButtonItem) {
        playlistsRouter?.openPlaylist(nil)
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
        return tableView.makePlaylistCell(playlist)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            presenter.playlistsDataSource.loadMoreIfNeeded()
        }
    }
    
    
    // MARK: - Table Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIDevice.isPad ? tableView.singleSelect(at: indexPath) : tableView.deselectRow(at: indexPath, animated: true)
        let playlist = presenter.playlistsDataSource.items[indexPath.row]
        playlistsRouter?.openPlaylist(playlist)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
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
        let api = SpotifyApi(cache: cache)
        let playlistPresenter = PlaylistPresenter(cache: cache, api: api)
        cache.delegate = playlistPresenter
        playlistPresenter.setPlaylist(playlist: playlist)
        return PlaylistViewController(presenter: playlistPresenter)
    }
    
    
    // MARK: - Base Presenter Delegate
    
    override func isUserAuthenticatedDidChange(_ isAuthenticated: Bool) {
        addButton.isEnabled = true
        isAuthenticated ? presenter.playlistsDataSource.refresh() : reloadTable()
    }
    
    override func isLoadingChanged(_ isLoading: Bool) {
        if presenter.playlistsDataSource.items.isEmpty && isLoading {
            reloadTable()
        }
    }
    
    
    // MARK: - Empty State Delegate
    
    override func onEmptyStateButtonTapped() {
        guard let state = getEmptyStateConfig()?.state else {
            return
        }
        
        switch state {
        case .authenticationChallenge:
            presenter.login(self)
        case .error:
            presenter.playlistsDataSource.refresh()
        case .empty:
            playlistsRouter?.openPlaylist(nil)
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
        reloadTable()
    }
    
    func newPlaylistDidChange(_ playlist: Playlist?) {
        addButton.isEnabled = true
        if let playlist = playlist {
            playlistsRouter?.openPlaylist(playlist)
        }
    }
}
