//
//  DropView.swift
//  FontManager
//
//  Created by Dylan Southard on 15/2/18.
//  Copyright © ค.ศ. 2018 Dylan Southard. All rights reserved.
//



import Cocoa

class DropView: NSView {
    var delegate:ViewController!
    
    var filePath: String?
    var folderPath:String?
    
    
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
        print("dragging entered")
        if checkExtension(sender) == true {
            self.layer?.backgroundColor = NSColor.blue.cgColor
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
        self.layer?.backgroundColor = NSColor.gray.cgColor
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        self.layer?.backgroundColor = NSColor.gray.cgColor
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        delegate.fontURL = self.getUrl(sender)!
        delegate.changeFont()
        return true
    }
    
    
}


