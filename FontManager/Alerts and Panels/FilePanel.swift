//
//  DirectoryPanel.swift
//  FontManager
//
//  Created by Dylan Southard on 2018/04/16.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Cocoa

class FilePanel: NSObject {
    let panel = NSOpenPanel()

    init(message:String, path:String, fileTypes:[String]) {
        super.init()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedFileTypes = fileTypes
        panel.message = message
        panel.directoryURL = URL(fileURLWithPath: path)
    }
}
