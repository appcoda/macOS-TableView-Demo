//
//  PurchasesDetailView.swift
//  TableDemo
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import Cocoa

class PurchasesDetailView: NSView, LoadableView {
    
    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var usernameLabel: NSTextField!
    
    @IBOutlet weak var avatarImageView: NSImageView!
    
    @IBOutlet weak var idLabel: NSTextField!
    
    @IBOutlet weak var creditCardNumberLabel: NSTextField!
    
    @IBOutlet weak var creditCardTypeLabel: NSTextField!
    
    @IBOutlet weak var purchasesLabel: NSTextField!
    
    @IBOutlet weak var amountLabel: NSTextField!
    
    
    // MARK: - Properties
    
    var mainView: NSView?
    
    
    
    // MARK: - Init
    
    init() {
        super.init(frame: NSRect.zero)
        
        _ = load(fromNIBNamed: "PurchasesDetailView")
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
