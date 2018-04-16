//
//  DirectoryPanel.swift
//  FontManager
//
//  Created by Dylan Southard on 2018/04/16.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Cocoa

class SavePanel: NSObject {
    let panel = NSSavePanel()
    var checkedButton:NSButton?

    init(message:String, url:String, checkBoxTitle:String? = nil) {
        super.init()
        self.panel.message = message
        self.panel.directoryURL = URL(string:url)
        let accessoryView = NSView(frame: CGRect(x: 0, y: 0, width: self.panel.frame.size.width, height: 32))
        if let checkTitle = checkBoxTitle {
            let button = NSButton(frame: CGRect(x: 50, y: 2, width: 200, height: 28))
            button.setButtonType(.switch)
            button.title = checkTitle
            accessoryView.addSubview(button)
            self.checkedButton = button
            self.panel.accessoryView = accessoryView
        }
        
    }
}
