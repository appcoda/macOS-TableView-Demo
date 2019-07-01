//
//  ViewController.swift
//  TableDemo
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var tableView: NSTableView!
    
    @IBOutlet weak var viewModeButton: NSButton?
    
    @IBOutlet weak var selectedAmountLabel: NSTextField?
    
    
    
    // MARK: - Properties
    
    var viewModel = ViewModel()
    
    var originalColumns = [NSTableColumn]()
    
    
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        originalColumns = tableView.tableColumns
        
        tableView.doubleAction = #selector(handleDoubleClick)
        
        setSortDescriptor()
    }

    
    override func viewWillAppear() {
        super.viewWillAppear()
        tableView.reloadData()
    }
    
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


    
    // MARK: - IBAction Methods
    
    @IBAction func switchDisplayMode(_ sender: Any) {
        viewModel.switchDisplayMode()
        
        if viewModel.displayMode == .detail {
            
            for column in tableView.tableColumns.reversed() {
                tableView.removeTableColumn(column)
            }
            
            let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "detailsColumn"))
            column.width = tableView.frame.size.width
            column.title = "Purchases Detailed View"
            tableView.addTableColumn(column)
            
            viewModeButton?.title = "Switch to Plain Display Mode"
            
        } else {
            
            tableView.removeTableColumn(tableView.tableColumns[0])
            
            for column in originalColumns {
                tableView.addTableColumn(column)
            }
            
            viewModeButton?.title = "Switch to Detail Display Mode"
            
        }
        
        tableView.reloadData()
    }
    
    
    
    
    // MARK: - Custom Methods
    
    func showAlert(forPurchase purchase: Purchases) {
        var user = "User"
        var displayAmount = "$0"
        if let username = purchase.userInfo?.username {
            user = username
        }
        if let amount = purchase.paymentInfo?.amount {
            displayAmount = amount
        }
        
        let alert = NSAlert()
        alert.messageText = "\(user) spent \(displayAmount) in purchases over the last 24 hours."
        alert.beginSheetModal(for: self.view.window!) { (response) in
            
        }
    }
    
    
    @objc func handleDoubleClick() {
        let clickedRow = tableView.clickedRow
        
        /*
         if clickedRow >= 0 {
            let purchase = viewModel.purchases[clickedRow]
            showAlert(forPurchase: purchase)
         }
         */
        
        if viewModel.displayMode == .plain {
            guard clickedRow >= 0,
                let row = tableView.rowView(atRow: clickedRow, makeIfNecessary: false),
                let cellView = row.view(atColumn: 0) as? NSTableCellView,
                let id = cellView.textField?.integerValue,
                let purchase = viewModel.getPurchase(withID: id)
                else { return }
            
            showAlert(forPurchase: purchase)
        } else {
            guard clickedRow >= 0,
                let row = tableView.rowView(atRow: clickedRow, makeIfNecessary: false),
                let view = row.view(atColumn: 0) as? PurchasesDetailView,
                let purchase = viewModel.getPurchase(withID: view.idLabel.integerValue)
                else { return }
            
            showAlert(forPurchase: purchase)
        }
    }
    
    
    
    func setSortDescriptor() {
        let idDescriptor = NSSortDescriptor(key: "id", ascending: true)
        tableView.tableColumns[0].sortDescriptorPrototype = idDescriptor
    }
}



// MARK: - NSTableViewDataSource
extension ViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return viewModel.purchases.count
    }
    
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        guard let sortDescriptor = tableView.sortDescriptors.first else { return }
        viewModel.sortPurchases(ascending: sortDescriptor.ascending)
        tableView.reloadData()
    }
}



// MARK: - NSTableViewDelegate
extension ViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let currentPurchase = viewModel.purchases[row]
        
        if viewModel.displayMode == .plain {
            if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "idColumn") {
                
                let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "idCell")
                guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
                cellView.textField?.integerValue = currentPurchase.id ?? 0
                return cellView
                
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "userInfoColumn") {
                
                let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "userInfoCell")
                guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
                cellView.textField?.stringValue = currentPurchase.userInfo?.username ?? ""
                
                if let avatarData = viewModel.getAvatarData(forUserWithID: currentPurchase.userInfo?.id) {
                    cellView.imageView?.image = NSImage(data: avatarData)
                }
                
                return cellView
                
            } else {
                
                let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "paymentInfoCell")
                guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? PaymentInfoCellView else { return nil }
                cellView.textField?.stringValue = currentPurchase.paymentInfo?.creditCard ?? ""
                cellView.creditCardTypeLabel?.stringValue = currentPurchase.paymentInfo?.creditCardType ?? ""
                cellView.amountLabel?.stringValue = currentPurchase.paymentInfo?.amount ?? ""
                
                cellView.purchasesPopup?.removeAllItems()
                cellView.purchasesPopup?.addItems(withTitles: currentPurchase.paymentInfo?.purchaseTypes ?? [])
                
                return cellView
                
            }
            
        } else {
            let view = PurchasesDetailView()
            view.usernameLabel.stringValue = currentPurchase.userInfo?.username ?? ""
            view.idLabel.integerValue = currentPurchase.id ?? 0
            
            if let avatarData = viewModel.getAvatarData(forUserWithID: currentPurchase.userInfo?.id) {
                view.avatarImageView.image = NSImage(data: avatarData)
            }
            
            view.creditCardNumberLabel.stringValue = currentPurchase.paymentInfo?.creditCard ?? ""
            view.creditCardTypeLabel.stringValue = currentPurchase.paymentInfo?.creditCardType ?? ""
            view.amountLabel.stringValue = currentPurchase.paymentInfo?.amount ?? ""
            view.purchasesLabel.stringValue = currentPurchase.paymentInfo?.purchaseTypes?.joined(separator: ", ") ?? ""
            
            return view
        }
        
    }
    
    
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if viewModel.displayMode == .plain {
            return 21.0
        } else {
            return 150.0
        }
    }
    
    
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let selectedRow = tableView.selectedRow
        
        if selectedRow >= 0 && tableView.selectedRowIndexes.count == 1 {
            if let amount = viewModel.purchases[selectedRow].paymentInfo?.amount {
                selectedAmountLabel?.stringValue = "Selected amount: \(amount)"
            }
        }
    }
    
    
    func tableView(_ tableView: NSTableView, rowActionsForRow row: Int, edge: NSTableView.RowActionEdge) -> [NSTableViewRowAction] {
        
        if edge == .leading {
            let printAction = NSTableViewRowAction(style: .regular, title: "Print") { (action, index) in
                print("Now printing...")
            }
            printAction.backgroundColor = NSColor.gray
            return [printAction]
            
        } else {
            let deleteAction = NSTableViewRowAction(style: .destructive, title: "Delete") { (action, index) in
                self.viewModel.removePurchase(atIndex: row)
                self.tableView.reloadData()
            }
            
            return [deleteAction]
        }
    }
    
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }
}

