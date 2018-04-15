//
//  NewProjectPopup.swift
//  
//
//  Created by Dylan Southard on 2018/04/15.
//

import Cocoa

class NewProjectPopup: NSAlert {
    
    //var textField:NSTextField!
    
    override init() {
        super.init()
        self.addButton(withTitle: "OK")      // 1st button
        self.addButton(withTitle: "Cancel")  // 2nd button
        self.messageText = "Please name the project"
        
        
        let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        //self.textField = txt
        self.accessoryView = txt
        
    }
}
