//
//  TextExampleVC.swift
//  FontManager
//
//  Created by Dylan Southard on 2018/04/14.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Cocoa

class TextExampleVC: NSViewController {

    var delegate:ViewController!
    let dataManager = EncodeManager()
    
    @IBOutlet weak var tableView: NSTableView!
    
    @IBOutlet weak var loadButton: NSButton!
    @IBOutlet weak var segmentedControl: NSSegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.toggleButtons()
    }
    
    func toggleButtons() {
        self.loadButton.isEnabled = self.tableView.selectedRow >= 0
        self.segmentedControl.setEnabled(self.tableView.selectedRow >= 0, forSegment: 1)
        self.segmentedControl.setEnabled(self.tableView.selectedRow >= 0, forSegment: 2)
    }
    
    
    //MARK: - Add/Remove/Edit
    
    @IBAction func addRemovePressed(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            self.presentEditor(new: true)
        } else if sender.selectedSegment == 1 {
            //delete
            if self.deleteConfirmed() {
                self.dataManager.exampleArray.remove(at: self.tableView.selectedRow)
                self.dataManager.saveExamples()
                self.tableView.reloadData()
            }
        } else if sender.selectedSegment == 2 {
            self.presentEditor(new: false)
        }
    }
    
    func presentEditor(new:Bool) {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let controller = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "ExampleTextEditor")) as! EditTextVC
        controller.textExVC = self
        if !new {
            controller.textExIn = self.tableView.selectedRow
        }
        self.presentViewControllerAsSheet(controller)
    }
    

    func deleteConfirmed()-> Bool {
        let alert = NSAlert()
        alert.messageText = "Delete?"
        alert.informativeText = "No backsies!"
        alert.alertStyle = NSAlert.Style.warning
        alert.addButton(withTitle: "Do it anyway")
        alert.addButton(withTitle: "Cancel")
        let res = alert.runModal()
        if res == NSApplication.ModalResponse.alertFirstButtonReturn {
            return true
        }
        return false
    }
    
    
    
    //MARK: - Load Button
    @IBAction func loadPressed(_ sender: Any) {
        if let cell = self.tableView.view(atColumn: 1, row: self.tableView.selectedRow, makeIfNecessary: false) as? NSTableCellView {
            self.delegate.fontDisplay.string = cell.textField!.stringValue
            self.dismiss(self)
        }
        
    }
    
    //MARK: - EDIT TEXT
    @objc func textDidEndEditing(_ notification:Notification) {
        
        NotificationCenter.default.removeObserver(self, name: NSControl.textDidEndEditingNotification, object: notification.object)
        
        
    }
}



extension TextExampleVC : NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.dataManager.exampleArray.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let rowData : [String:String] = ["Title":self.dataManager.exampleArray[row].name, "Text":self.dataManager.exampleArray[row].text]
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        cell.textField!.stringValue = rowData[tableColumn!.identifier.rawValue]!
        NotificationCenter.default.addObserver(self, selector: #selector(textDidEndEditing(_:)), name: NSControl.textDidEndEditingNotification, object: cell.textField!)
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        self.toggleButtons()
    }
}


