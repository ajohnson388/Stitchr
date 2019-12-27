//
//  BaseTableViewController.swift
//  Stitcher
//
//  Created by Andrew Johnson on 1/31/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import UIKit
import Anchorage

/// Provides basic behavior for interacting with a base presenter and showing or hiding empty table states.
class BaseTableViewController<T>: UITableViewController, BasePresenterDelegate where T: BasePresenter {
    
    // MARK: - Properties
    
    let emptyView = EmptyView(frame: .null)
    let presenter: T
    
    
    // MARK: - Lifecycle
    
    init(presenter: T) {
        self.presenter = presenter
        super.init(style: .grouped)
        presenter.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delaysContentTouches = false
    }
    
    
    // MARK: - TableView Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    // MARK: - Helper Functions
    
    func getEmptyStateConfig() -> EmptyStateConfig? {
        if !presenter.isAuthenticated {
            return EmptyStateConfig.makeAuthorization()
        } else if presenter.isLoading {
            return EmptyStateConfig.makeLoading()
        } else if let error = presenter.error {
            return EmptyStateConfig.makeError(message: error)
        } else {
            return nil
        }
    }
    
    func showEmptyState() {
        guard let config = getEmptyStateConfig() else {
            return
        }
        tableView.backgroundView = emptyView
        tableView.isScrollEnabled = presenter.isAuthenticated
        emptyView.buttonTitle = config.buttonTitle
        emptyView.image = config.image
        emptyView.subtitle = config.description
        emptyView.title = config.title
        emptyView.setButtonListener(onButtonTapped: onEmptyStateButtonTapped)
    }
    
    func hideEmptyState() {
        tableView.backgroundView = nil
        tableView.isScrollEnabled = true
    }
    
    func reloadTable() {
        if tableView.numberOfSections == 1 && tableView.numberOfRows(inSection: 0) == 0 {
            tableView.beginUpdates()
            tableView.reloadSections(IndexSet(integer: 0), with: .fade)
            tableView.endUpdates()
        } else {
            tableView.reloadData()
        }
        tableView.isEmpty ? showEmptyState() : hideEmptyState()
    }
    
    
    // MARK: - Delegates
    
    func isUserAuthenticatedDidChange(_ isAuthenticated: Bool) {}
    func isLoadingChanged(_ isLoading: Bool) {}
    func errorDidChange(_ error: String?) {
        if error != nil {
            reloadTable()
        }
    }
    
    func onEmptyStateButtonTapped() {
        
    }
}
