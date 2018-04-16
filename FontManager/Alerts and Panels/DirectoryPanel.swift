//
//  DirectoryPanel.swift
//  FontManager
//
//  Created by Dylan Southard on 2018/04/16.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Cocoa

class DirectoryPanel: NSObject {
    let panel = NSOpenPanel()

    init(message:String, url:String) {
        super.init()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.message = message
        panel.directoryURL = URL(string:url)
    }
}
