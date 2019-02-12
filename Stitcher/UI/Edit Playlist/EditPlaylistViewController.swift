//
//  EditPlaylistViewController.swift
//  Stitcher
//
//  Created by Andrew Johnson on 2/11/19.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import Foundation
import UIKit
import Hero
import Anchorage

protocol EditPlaylistViewControllerDelegate: class {
    func playlistTitleDidChange(title: String)
}

final class EditPlaylistViewController: UIViewController {
    
    // MARK: - Properties
    
    static let transitionId = "editPlaylistTransition"
    
    weak var delegate: EditPlaylistViewControllerDelegate?
    var presenter: EditPlaylistPresenter!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var containerView: UIView!
    
    
    // MARK: - Lifecycle
    
    static func make() -> EditPlaylistViewController {
        let name = "EditPlaylistViewController"
        return UIStoryboard(name: name, bundle: nil).instantiateViewController(withIdentifier: name) as! EditPlaylistViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        titleTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        titleTextField.resignFirstResponder()
    }
    
    private func setupView() {
        containerView.backgroundColor = Themes.current.primaryDarkColor
        navigationItem.largeTitleDisplayMode = .never
        titleTextField.text = presenter.playlist?.name
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel(_:)))
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSave(_:)))
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = saveButton
        navigationItem.hidesBackButton = true
    }
    
    @objc
    func didTapCancel(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    func didTapSave(_ sender: UIBarButtonItem) {
        presenter.savePlaylistTitle(titleTextField.text)
    }
}


// MARK: - Presenter Delegate

extension EditPlaylistViewController: EditPlaylistPresenterDelegate {
    
    func isUserAuthenticatedDidChange(_ isAuthenticated: Bool) {
        
    }
    
    func errorDidChange(_ error: String?) {
        
    }
    
    func isLoadingChanged(_ isLoading: Bool) {
        
    }
    
    func playlistTitleDidSave(_ isSaved: Bool) {
        if isSaved {
            delegate?.playlistTitleDidChange(title: titleTextField.text ?? "")
            navigationController?.popViewController(animated: true)
        }
    }
}
