//
//  ConfirmationAlert.swift
//  FontManager
//
//  Created by Dylan Southard on 2018/04/16.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Cocoa

class ConfirmationAlert: NSAlert {
    
    init(title:String, detail:String) {
        super.init()
        self.messageText = title
        self.informativeText = detail
        self.alertStyle = NSAlert.Style.warning
        self.addButton(withTitle: "Do it anyway")
        self.addButton(withTitle: "Cancel")
    }
}
