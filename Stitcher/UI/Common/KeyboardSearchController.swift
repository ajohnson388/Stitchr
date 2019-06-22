//
//  KeyboardSearchController.swift
//  Stitcher
//
//  Created by Giulio Montagner on 22/06/2019.
//  Copyright © 2019 Meaningless. All rights reserved.
//
import UIKit

class KeyboardSearchController: UISearchController, KeyboardSearchBarDelegate {
    
    var mySearchBar = KeyboardSearchBar()

    override var searchBar: KeyboardSearchBar {
        get{
            mySearchBar.delegate = self
            return mySearchBar;
        }
    }
    
    weak var keyboardSearchControllerDelegate: KeyboardSearchControllerDelegate?
    override weak var delegate: UISearchControllerDelegate? {
        didSet {
            keyboardSearchControllerDelegate = delegate as? KeyboardSearchControllerDelegate
        }
    }
    
    func downArrowButtonPressed() {
        if(keyboardSearchControllerDelegate != nil) {
            keyboardSearchControllerDelegate?.didStartResultSelectionFromKeyboard(searchController: self)
        }
    }
    
}

protocol KeyboardSearchControllerDelegate: UISearchControllerDelegate {
    
    func didStartResultSelectionFromKeyboard(searchController: UISearchController)
    
}
