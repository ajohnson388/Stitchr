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

final class PlaylistsViewController: UITableViewController {
    
    // MARK: - Properties
    
    private let presenter: PlaylistsPresenter
    private let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
    
    
    // MARK: - Lifecycle
    
    init(presenter: PlaylistsPresenter) {
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
        if presenter.isAuthenticated {
            presenter.fetchPlaylists()
        }
    }
    
    
    // MARK: - Event Callbacks
    
    @objc
    private func addButtonTapped(_ button: UIBarButtonItem) {
        openPlaylist(playlist: nil)
    }
    
    @objc
    private func didRefreshTable(_ refreshControl: UIRefreshControl) {
        presenter.fetchPlaylists()
    }
    
    
    // MARK: - Table Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.playlists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let playlist = presenter.playlists[indexPath.row]
        return ViewFactory.makePlaylistTableViewCell(tableView, indexPath: indexPath, playlist: playlist)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        ViewFactory.loadImage(presenter.playlists[indexPath.row].images.last?.url, forCell: cell)
    }
    
    
    // MARK: - Table Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Navigate to the playlist
        let playlist = presenter.playlists[indexPath.row]
        openPlaylist(playlist: playlist)
    }
    
    
    // MARK: - Setup Functions
    
    private func setupView() {
        setupAddButton()
        setupNavBar()
        setupLogoImage()
        setupTableView()
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
        navigationItem.title = "Playlists"
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
    
    private func openPlaylist(playlist: Playlist?) {
        let cache = LocalCache()
        let spotifyApi = SpotifyApi(cache: cache)
        let playlistPresenter = PlaylistPresenter(cache: cache, spotifyApi: spotifyApi)
        playlistPresenter.setPlaylist(playlist: playlist)
        let playlistViewController = PlaylistViewController(presenter: playlistPresenter)
        navigationController?.pushViewController(playlistViewController, animated: true)
    }
}

extension PlaylistsViewController: PlaylistsPresenterDelegate {
    
    func playlistsDidChange(_ playlists: [Playlist]) {
        tableView.refreshControl?.endRefreshing()
        tableView.reloadData()
    }
    
    func isUserAuthenticatedDidChange(_ isAuthenticated: Bool) {
        addButton.isEnabled = true
        presenter.fetchPlaylists()
    }
    
    func newPlaylistDidChange(_ playlist: Playlist?) {
        addButton.isEnabled = true
        if let playlist = playlist {
            openPlaylist(playlist: playlist)
        }
    }
    
    func errorDidChange(_ error: String?) {
        tableView.reloadEmptyDataSet()
    }
    
    func isLoadingChanged(_ isLoading: Bool) {
        // TODO: Fix crash
//        let isRefreshing = tableView.refreshControl?.isRefreshing ?? false
//        if !isRefreshing && isLoading {
//            tableView.refreshControl?.beginRefreshing()
//        } else if (!isLoading) {
//            tableView.refreshControl?.endRefreshing()
//        }
    }
}

extension PlaylistsViewController: DZNEmptyDataSetSource {
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        if !presenter.isAuthenticated {
            return Strings.loginRequiredTitle.localized.attributed
        } else if presenter.error != nil {
            return Strings.errorTitle.localized.attributed
        } else {
            return Strings.playlistsEmptyTitle.localized.attributed
        }
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        if !presenter.isAuthenticated {
            return Strings.loginRequiredDescription.localized.attributed
        } else if let error = presenter.error {
            return error.attributed
        } else {
            return Strings.playlistsEmptyDescription.localized.attributed
        }
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return tableView.backgroundColor
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControl.State) -> NSAttributedString! {
        if !presenter.isAuthenticated {
            return Strings.loginRequiredButtonTitle.localized.attributed
        } else if presenter.error != nil {
            return Strings.errorButtonTitle.localized.attributed
        } else {
            return Strings.emptyPlaylistsButtonTitle.localized.attributed
        }
    }
}

extension PlaylistsViewController: DZNEmptyDataSetDelegate {
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        if !presenter.isAuthenticated {
            presenter.login(viewController: self)
        } else if presenter.error != nil {
            presenter.fetchPlaylists()
        } else {
            openPlaylist(playlist: nil)
        }
    }
}
