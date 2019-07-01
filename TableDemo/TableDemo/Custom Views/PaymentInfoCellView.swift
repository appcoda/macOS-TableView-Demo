//
//  PaymentInfoCellView.swift
//  TableDemo
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import Cocoa

class PaymentInfoCellView: NSTableCellView {
    
    @IBOutlet weak var creditCardTypeLabel: NSTextField?
    @IBOutlet weak var amountLabel: NSTextField?
    @IBOutlet weak var purchasesPopup: NSPopUpButton?
}
