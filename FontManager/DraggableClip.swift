//
//  DraggableClip.swift
//  FontManager
//
//  Created by Dylan Southard on 2018/02/25.
//  Copyright © 2018年 Dylan Southard. All rights reserved.
//

import Cocoa

class DraggableClip: NSClipView {
    var delegate:ViewController!
    var filePath: String?
    var originalColor = NSColor()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.gray.cgColor
        registerForDraggedTypes([NSPasteboard.PasteboardType.URL])
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        
        if checkExtension(sender) == true {
            print("extension OK")
            self.originalColor = self.delegate.folderTree.backgroundColor
            self.delegate.folderTree.backgroundColor = NSColor.lightGray
            return .copy
        } else {
            return NSDragOperation()
        }
    }
    
    func getUrl(_ drag: NSDraggingInfo)-> URL? {
        guard let board = drag.draggingPasteboard().propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
            let path = board[0] as? String
            else { return nil}
        
        return URL(fileURLWithPath: path)
    }
    
    func checkExtension(_ drag: NSDraggingInfo) -> Bool {
        if let url = self.getUrl(drag) {
            return url.hasDirectoryPath
        }
        return false
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
       
        self.delegate.folderTree.backgroundColor = self.originalColor
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
    
    }
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        self.delegate.folderTree.backgroundColor = self.originalColor
        self.delegate.importer.importFilesFromDirectory(urls: [self.getUrl(sender)!])
        return true
    }
    
}
