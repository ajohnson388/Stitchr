//
//  PaginationDataSource.swift
//  Stitcher
//
//  Created by Andrew Johnson on 2/26/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation

/**
    The data results from the paginated data source.
 */
enum PagerResult<T> {
    case success(items: [T])
    case error
}

/**
    An abstract class for implementing a generic pagination data source. Callback methods should be implemented
    for the pager to function.
 */
class PaginationDataSource<T> {
    
    // MARK: - Properties
    
    var batchSize: Int = 11
    
    private var nextStartIndex: Int = 0
    private var isExhausted = false
    private(set) var items: [T] = [] {
        didSet {
            itemsDidUpdate(items)
        }
    }
    
    
    // MARK: - Control Methods
    
    func refresh() {
        nextStartIndex = 0
        isExhausted = false
        fetchItems(withOverwrite: true)
    }
    
    func loadMoreIfNeeded() {
        guard !isExhausted else {
            return
        }
        fetchItems()
    }
    
    
    // MARK: - Helper Functions
    
    private func fetchItems(withOverwrite overwrite: Bool = false) {
        fetchItems(startIndex: nextStartIndex, amount: batchSize) { (result: PagerResult<T>) in
            switch result {
            case .success(let items):
                self.isExhausted = items.count != self.batchSize
                self.nextStartIndex = self.nextStartIndex + self.batchSize
                if overwrite {
                    self.items = self.filterItems(items)
                } else {
                    self.items += self.filterItems(items)
                }
            case .error:
                break
            }
        }
    }
    
    
    // MARK: - Callback Functions
    
    /**
        Called when new items are needed to be loaded.
     */
    func fetchItems(startIndex: Int, amount: Int, completion: @escaping (PagerResult<T>) -> ()) {
        completion(PagerResult.success(items: []))
    }
    
    /**
        Called when the new items have been fetched or removed.
     */
    func itemsDidUpdate(_ items: [T]) {
        
    }
    
    /**
        Optional method that when overridden, allows items to be filtered by any means without
        any effects from the start index placement.
     */
    func filterItems(_ items: [T]) -> [T] {
        return items
    }
}
