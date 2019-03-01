//
//  SearchDataSource.swift
//  Stitcher
//
//  Created by Andrew Johnson on 2/28/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation

protocol SearchDataSourceDelegate: class {
    func fetchItems(startIndex: Int, amount: Int, completion: @escaping (PagerResult<Track>) -> ())
    func itemsDidUpdate(_ items: [Track])
    func filterItems(_ items: [Track]) -> [Track]
}

final class SearchDataSource: PaginationDataSource<Track> {
    
    weak var delegate: SearchDataSourceDelegate?
    
    override func fetchItems(startIndex: Int, amount: Int, completion: @escaping (PagerResult<Track>) -> ()) {
        delegate?.fetchItems(startIndex: startIndex, amount: amount, completion: completion)
    }
    
    override func itemsDidUpdate(_ items: [Track]) {
        delegate?.itemsDidUpdate(items)
    }
    
    override func filterItems(_ items: [Track]) -> [Track] {
        return delegate?.filterItems(items) ?? []
    }
}
