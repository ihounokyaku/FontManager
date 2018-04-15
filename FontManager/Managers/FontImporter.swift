//
//  FontImporter.swift
//  FontManager
//
//  Created by Dylan Southard on 2018/02/24.
//  Copyright © 2018年 Dylan Southard. All rights reserved.
//

import Cocoa

class FontImporter: NSObject {

    var delegate:ViewController!

//=========== IMPORT FROM DIRECTORY ============================
    func chooseFontDirectory() {
        let panel = self.delegate.directoryPanel(message: "Please select your Directory", url: "")
        panel.beginSheetModal(for: delegate.view.window!, completionHandler: {(response) -> Void in
            if response == .cancel{
                
            } else {
                self.importFilesFromDirectory(url: panel.url!)
            }
        })
    }
    
    func importFilesFromDirectory(url:URL) {
        
        
        if self.checkDirectory(url: url) {
            let (fontURLs, subDirectories) = self.getFontFiles(folderUrl: url)
            if fontURLs.count == 0 {
                print("no fonts")
                return
            }
            self.delegate.enableDisableEverything(false)
            
            DispatchQueue.global(qos: .background).async {
                //- define variables
                var index = 0
                var errors = [String]()
                
                var newFonts = [[String:Any?]]()
                
                //- iterate through each url
            for fontURL in fontURLs{
                
                var subDirectory:String?
                for (name, urls) in subDirectories {
                    if urls.contains(fontURL) {
                        subDirectory = name
                    }
                }
                
                let fontName = fontURL.deletingPathExtension().lastPathComponent
                var coreDataResults:NSManagedObject?
                
                DispatchQueue.main.async {
                     self.delegate.statusLabel.stringValue = "Checking Fonts - " + fontName
                }
                // - check in coredata
                coreDataResults = self.delegate.dataManager.objectInCoreData(entityName: "Font", attribute: "fileName", name: fontName)
                
                if let font = coreDataResults as? Font {
                    if font.path != fontURL.path {
                        newFonts.append(["font":font, "path":fontURL.path, "subdirectory":subDirectory])
                    }
                } else {
                    
                    if let font = fontURL.path.nsFont(self.delegate) {
                        newFonts.append(["font":font, "path":fontURL.path, "subdirectory":subDirectory])
                        
                    } else {
                        errors.append(fontURL.deletingPathExtension().lastPathComponent)
                    }
                }
                index += 1
                if index == fontURLs.count {
                    
                    DispatchQueue.main.async {
                        self.updateFontUrls(fonts: newFonts)
                        self.delegate.statusLabel.stringValue = ""
                        self.delegate.errorFromArray(title: "Could not get the following fonts:", errors: errors)
                        self.delegate.getAllFonts()
                        self.delegate.enableDisableEverything(true)
                    }
                }else {
                    print("index = \(index) and font urls = \(fontURLs.count)")
                }
            }
        }
           
        }
    }
    
    func updateFontUrls(fonts:[[String:Any?]], folderPath:String) {
        
        for fontObject in fonts {
            var font:Font!
            var path = fontObject["path"] as! String
            var subdirectory = fontObject["subdirectory"] as! String
            
            if let nsFont = fontObject["font"] as? NSFont {
                //- create new font from NSFont
                font = self.delegate.dataManager.newFont(fontFile:nsFont, path: path)
            } else {
                font = fontObject["font"] as! Font
                
            }
            
            self.delegate.dataManager.recordDirectories(mainDirectory: folderPath, subDirectory: subdirectory, font: font)
            
        }
        
    }
    
    func getFontFiles(folderUrl:URL) -> ([URL], [String:[URL]]) {
        var urls = [URL]()
        var subFolders = [String:[URL]]()
        let fileTypes = ["ttf", "otf"]
        let allURLs = self.getFolderContents(url: folderUrl)
        for url in allURLs {
            if fileTypes.contains(url.pathExtension) {
                urls.append(url)
            } else if url.hasDirectoryPath {
                let (new, _) = self.getFontFiles(folderUrl: url)
                if new.count > 1 {
                    subFolders[url.path] = new
                }
                urls += new
            }
        }
        return (urls, subFolders)
    }
    
    func checkDirectory (url:URL)->Bool {
        if url.hasDirectoryPath {
            return true
        } else {
            self.delegate.errorAlert("Error!", detail: "Could not find folder")
            return false
        }
    }
    
    func getFolderContents(url:URL) -> [URL] {
        var urls = [URL]()
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: url.path)
            urls = contents.map { return url.appendingPathComponent($0) }
        } catch let error as NSError {
            self.delegate.errorAlert("Error reading folder contents!", detail: "\(error)")
        }
        return urls
    }
    
    
//=================REMOVE FOLDERS ================================
    
    func removeFolders(_ folders:[FontFolder]) {
        for folder in folders {
            let fonts = Array(folder.fonts!) as! [Font]
            let subdirectories = Array(folder.subFolders!) as! [FontFolder]
            for font in fonts {
                folder.removeFromFonts(font)
                for subdirectory in subdirectories {
                    subdirectory.removeFromFonts(font)
                }
                if font.directories!.count == 0 {
                    
                    self.delegate.dataManager.deleteFont(font)
                }
            }
            self.delegate.dataManager.context.delete(folder)
            self.delegate.dataManager.saveContext()
        }
        
        self.delegate.reloadAll()
        
    }
    func reloadAfterFolderTreeChange() {
        self.delegate.folderTree.reloadData()
        self.delegate.tagTable.reloadData()
        self.delegate.populateFontWindow()
        self.delegate.reloadFontView()
        
    }
}

