//
//  PlaylistsDataSource.swift
//  Stitcher
//
//  Created by Andrew Johnson on 2/27/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation

protocol PlaylistsDataSourceDelegate: class {
    func fetchItems(startIndex: Int, amount: Int, completion: @escaping (PagerResult<Playlist>) -> ())
    func itemsDidUpdate(_ items: [Playlist])
    func filterItems(_ items: [Playlist]) -> [Playlist]
}

final class PlaylistsDataSource: PaginationDataSource<Playlist> {
    
    weak var delegate: PlaylistsDataSourceDelegate?
    
    override func fetchItems(startIndex: Int, amount: Int, completion: @escaping (PagerResult<Playlist>) -> ()) {
        delegate?.fetchItems(startIndex: startIndex, amount: amount, completion: completion)
    }

    override func itemsDidUpdate(_ items: [Playlist]) {
        delegate?.itemsDidUpdate(items)
    }
    
    override func filterItems(_ items: [Playlist]) -> [Playlist] {
        return delegate?.filterItems(items) ?? []
    }
}
