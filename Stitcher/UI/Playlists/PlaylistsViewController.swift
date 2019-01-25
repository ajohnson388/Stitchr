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

final class PlaylistsViewController: UITableViewController {
    
    // MARK: - Properties
    
    private let presenter: PlaylistsPresenter
    
    
    // MARK: - Lifecycle
    
    init(presenter: PlaylistsPresenter = PlaylistsPresenter()) {
        self.presenter = presenter
        super.init(style: .plain)
        presenter.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.login(viewController: self)
        navigationItem.title = "Playlists"
    }
    
    
    // MARK: - Setup
    
    private func addFloatingActionButton() {
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    
    // MARK: - Event Callbacks
    
    
    // MARK: - Table Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.playlists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseId = "playlistCell"
        let playlist = presenter.playlists[indexPath.row]
        let imageURlString = playlist.images.first?.url
        let imageUrl = imageURlString == nil ? nil : try? imageURlString!.asURL()
        let placeholder: UIImage? = nil
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId) ?? UITableViewCell(style: .subtitle, reuseIdentifier: reuseId)
        cell.textLabel?.text = playlist.name
        cell.detailTextLabel?.text = "\(playlist.tracks.total) songs"
        cell.imageView?.sd_setImage(with: imageUrl, placeholderImage: placeholder)
        cell.textLabel?.textColor = Themes.current.primaryTextColor
        cell.detailTextLabel?.textColor = Themes.current.primaryTextColor
        return cell
    }
    
    
    // MARK: - Table Delegate
    
    
    // MARK: - Helper Functions
    
    private func showEmptyPlaylists() {
        let textField = UITextField(frame: CGRect.null)
        textField.text = "Your playlists are looking a little empty.. \n Tap '+' to create one."  // TODO: Abstract string
        tableView.backgroundView = textField
    }
    
    private func showPlaylistsError() {
        
    }
}

extension PlaylistsViewController: PlaylistsPresenterDelegate {
    
    func playlistsDidChange(_ playlists: [Playlist]) {
        tableView.reloadData()
        if (playlists.count == 0) {
            showEmptyPlaylists()
        } else {
            tableView.backgroundView = nil
        }
    }
    
    func isUserAuthenticatedDidChangfe(_ isAuthenticated: Bool) {
        presenter.fetchPlaylists()
    }
}
