//
//  EditTextVC.swift
//  FontManager
//
//  Created by Dylan Southard on 2018/04/14.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Cocoa

class EditTextVC: NSViewController, NSTextFieldDelegate {
    @IBOutlet weak var titleView: NSTextField!
    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var saveButton: NSButton!
    
    var str = ""
    var textExVC:TextExampleVC?
    let dataManager = EncodeManager()
    
    var textExIn:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textField.delegate = self
        self.titleView.delegate = self
        
        self.textField.stringValue = self.str
        if self.textExIn == nil {
            self.dataManager.exampleArray.append(ExampleText())
           self.textExIn =  dataManager.exampleArray.count - 1
        } else {
            self.titleView.stringValue = self.dataManager.exampleArray[self.textExIn!].name
            self.textField.stringValue = self.dataManager.exampleArray[self.textExIn!].text
        }
        self.toggleSave()
        // Do view setup here.
    }
    
    @IBAction func savePressed(_ sender: Any) {
        
        self.dataManager.exampleArray[textExIn!].name = self.titleView.stringValue
        self.dataManager.exampleArray[textExIn!].text = self.textField.stringValue

            self.dataManager.saveExamples()
            if let del = self.textExVC {
                del.dataManager.loadExamples()
                del.tableView.reloadData()
            }
            self.dismiss(self)
        
    }
    
    func toggleSave() {
        saveButton.isEnabled = self.titleView.stringValue != "" && self.textField.stringValue != ""
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        self.toggleSave()
    }
    
    
    
}
