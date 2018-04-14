//
//  TagCell.swift
//  FontManager
//
//  Created by Dylan Southard on 2018/02/23.
//  Copyright © 2018年 Dylan Southard. All rights reserved.
//

import Cocoa

class CustomCell: NSTableCellView {

    var fontTag:Tag?
    //var font:Font?
    var table:NSTableView!
    
    @IBOutlet weak var removeButton: NSButton?
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
    @IBAction func removePressed(_ sender: Any) {
        self.textField?.stringValue = ""
    }
}
