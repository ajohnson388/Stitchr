//
//  TracksDataSource.swift
//  Stitcher
//
//  Created by Andrew Johnson on 2/28/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation

protocol TracksDataSourceDelegate: class {
    func fetchItems(startIndex: Int, amount: Int, completion: @escaping (PagerResult<TrackItem>) -> ())
    func itemsDidUpdate(_ items: [TrackItem])
    func filterItems(_ items: [TrackItem]) -> [TrackItem]
}

final class TracksDataSource: PaginationDataSource<TrackItem> {
    
    weak var delegate: TracksDataSourceDelegate?
    
    override func fetchItems(startIndex: Int, amount: Int, completion: @escaping (PagerResult<TrackItem>) -> ()) {
        delegate?.fetchItems(startIndex: startIndex, amount: amount, completion: completion)
    }
    
    override func itemsDidUpdate(_ items: [TrackItem]) {
        delegate?.itemsDidUpdate(items)
    }
    
    override func filterItems(_ items: [TrackItem]) -> [TrackItem] {
        return delegate?.filterItems(items) ?? []
    }
}
