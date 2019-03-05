//
//  PaginationDataSource.swift
//  Stitcher
//
//  Created by Andrew Johnson on 2/26/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation

/// The data results from the paginated data source.
///
/// - success: A successful result that contains the fetched data.
/// - error: An unsucessful result.
enum PagerResult<T> {
    case success(items: [T])
    case error
}

/// An abstract class for implementing a generic pagination data source.
/// Callback methods should be implemented for the pager to function.
class PaginationDataSource<T> {
    
    // MARK: - Properties
    
    /// The max number of items to fetch when loading data.
    var batchSize: Int = 20
    
    private var nextStartIndex: Int = 0
    private var isExhausted = false
    private(set) var items: [T] = [] {
        didSet {
            itemsDidUpdate(items)
        }
    }
    
    
    // MARK: - Control Methods
    
    /// Removes an item from the data source.
    ///
    /// - Parameter index: The index of the item to remove.
    func removeItem(at index: Int) {
        _ = items.remove(at: index)
        if nextStartIndex > 0 {
            nextStartIndex -= 1
        }
    }
    
    /// Moves an item from one position to another in the data source.
    ///
    /// - Parameters:
    ///   - fromIndex: The index of the item to move.
    ///   - toIndex: The index to where the move the item.
    func moveItem(from fromIndex: Int, to toIndex: Int) {
        let item = items.remove(at: fromIndex)
        items.insert(item, at: toIndex)
    }
    
    /// Resets the data source and loads the first set of data.
    func refresh() {
        nextStartIndex = 0
        isExhausted = false
        fetchItems(withOverwrite: true)
    }
    
    /// Triggers a fetch to load more data if the data source is not exhausted.
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
    
    /// Called when new items are needed to be loaded.
    ///
    /// - Parameters:
    ///   - startIndex: The index in the cursor to fetch at.
    ///   - amount: The amount of items to fetch from the start index.
    ///   - completion: A callback that returns the result of the fetch.
    func fetchItems(startIndex: Int, amount: Int, completion: @escaping (PagerResult<T>) -> ()) {
        completion(PagerResult.success(items: []))
    }

    /// Called when the new items have been fetched or removed.
    ///
    /// - Parameter items: The items after the update.
    func itemsDidUpdate(_ items: [T]) {
        
    }
    
    /// Optional method that when overridden, allows items to be filtered by any means without
    /// any effects from the start index placement.
    ///
    /// - Parameter items: The items to filter.
    /// - Returns: The filtered items.
    func filterItems(_ items: [T]) -> [T] {
        return items
    }
}
