//
//  KeyboardSearchBar.swift
//  Stitcher
//
//  Created by Giulio Montagner on 22/06/2019.
//  Copyright © 2019 Meaningless. All rights reserved.
//

import UIKit

class KeyboardSearchBar: UISearchBar {
    
    var selectBelowDiscoverabilityTitle = "Select First Result"
    
    override var keyCommands: [UIKeyCommand]? {
        get {
            var commands = super.keyCommands ?? []
            
            commands.append(UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: [], action: #selector(downArrowPressed), discoverabilityTitle: selectBelowDiscoverabilityTitle))
            return commands
        }
    }
    
    @objc private func downArrowPressed() {
        resignFirstResponder()
        if(arrowKeyDelegate != nil) {
            arrowKeyDelegate?.downArrowButtonPressed()
        }
    }
    
    weak var arrowKeyDelegate: KeyboardSearchBarDelegate?
    override weak var delegate: UISearchBarDelegate? {
        didSet {
            arrowKeyDelegate = delegate as? KeyboardSearchBarDelegate
        }
    }
    
}


protocol KeyboardSearchBarDelegate: UISearchBarDelegate {
    
    func downArrowButtonPressed()
    
}
