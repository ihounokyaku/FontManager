//
//  AddToProjectVC.swift
//  FontManager
//
//  Created by Dylan Southard on 2018/04/15.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Cocoa

class AddToProjectVC: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var segmentedController: NSSegmentedControl!
    
    var fonts = [String]()
    
    let encoder = ProjectEncoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.toggleAdd()
    }
    
    func toggleAdd() {
        self.segmentedController.setEnabled(self.tableView.selectedRow >= 0, forSegment: 1)
    }
    
    @IBAction func cancelAddPressed(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 1 {
            self.encoder.projectArray[self.tableView.selectedRow].fonts += self.fonts
            self.encoder.saveProjects()
        }
        self.dismiss(self)
    }
    
    
    //MARK: - TableView Stuff
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.encoder.projectArray.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        cell.textField?.stringValue = self.encoder.projectArray[row].name
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        self.toggleAdd()
    }
    
}
