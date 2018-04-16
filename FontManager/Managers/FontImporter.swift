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
        let panel = DirectoryPanel(message: "Please select your Directory", url: "").panel
        panel.beginSheetModal(for: delegate.view.window!, completionHandler: {(response) -> Void in
            if response == .cancel{
                
            } else {
                self.importFilesFromDirectory(urls: [panel.url!])
            }
        })
    }
    
    func importFilesFromDirectory(urls:[URL]) {
        self.delegate.stopLoading = false
        //self.delegate.refreshButton.ay.startLoading()
        self.delegate.refreshButton.title = "Stop"
        var fontURLs = [[String:URL]]()
        var subDirectories = [String : [URL]]()
        for url in urls {
        if self.checkDirectory(url: url) {
            
            let (fUrls, sds) = self.getFontFiles(folderUrl: url)
            for fUrl in fUrls {
                fontURLs.append(["fontUrl":fUrl, "mainFolderUrl":url])
            }
            for (name, subUrls) in sds {
                subDirectories[name] = subUrls
            }
            }
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
                
                
                
                if self.delegate.stopLoading == true {
                    
                    DispatchQueue.main.async {
                        self.delegate.statusLabel.stringValue = ""
                        self.delegate.refreshButton.title = "Refresh"
                        self.delegate.enableDisableEverything(true)
                    }
                    
                    
                    return
                }
                var subDirectory:String?
                for (name, subUrls) in subDirectories {
                    if subUrls.contains(fontURL["fontUrl"]!) {
                        subDirectory = name
                    }
                }
                
                let fontName = fontURL["fontUrl"]!.deletingPathExtension().lastPathComponent
                var message = "Checking Fonts - " + fontName
                if index == fontURLs.count - 1 {
                    message = "Saving... (this may look frozen for a moment, but it's just doing its job)"
                }
                
                DispatchQueue.main.async {
                   
                        self.delegate.statusLabel.stringValue = message
        
                    
                }
                // - check in coredata
                var coreDataResults:NSManagedObject?
                coreDataResults = self.delegate.dataManager.objectInCoreData(entityName: "Font", attribute: "fileName", name: fontName)
                
                if let font = coreDataResults as? Font {
                    if font.path != fontURL["fontUrl"]!.path {
                        DispatchQueue.main.async {
                            newFonts.append(["font":font, "path":fontURL["fontUrl"]!.path, "mainDirectoryPath":fontURL["mainFolderUrl"]!.path, "subdirectory":subDirectory])
                        }
                    }
                } else {
                    
                    if let font = fontURL["fontUrl"]!.path.nsFont(self.delegate) {
                         newFonts.append(["font":font, "path":fontURL["fontUrl"]!.path, "mainDirectoryPath":fontURL["mainFolderUrl"]!.path, "subdirectory":subDirectory])
                        
                    } else {
                        errors.append(fontURL["fontUrl"]!.deletingPathExtension().lastPathComponent)
                    }
                }
                index += 1
                if index == fontURLs.count {
                    
                    DispatchQueue.main.async {
                       
                        self.updateFontUrls(fonts: newFonts)
                        self.delegate.statusLabel.stringValue = ""
                        self.delegate.errorFromArray(title: "Could not get the following fonts:", errors: errors)
                        //self.delegate.refreshButton.ay.stopLoading()
                        self.delegate.refreshButton.title = "Refresh"
                        self.delegate.stopLoading = false
                        self.delegate.getAllFonts()
                        self.delegate.enableDisableEverything(true)
                    }
                }else {
                    //print("index = \(index) and font urls = \(fontURLs.count)")
                }
            }
        }
           
        }
    }
    
    func updateFontUrls(fonts:[[String:Any?]]) {
        
        for fontObject in fonts {
            var font:Font!
            let folderPath = fontObject["mainDirectoryPath"] as! String
            let path = fontObject["path"] as! String
            let subdirectory = fontObject["subdirectory"] as? String
            if let nsFont = fontObject["font"] as? NSFont {
                //- create new font from NSFont
                font = self.delegate.dataManager.newFont(fontFile:nsFont, path: path)
            } else {
                font = fontObject["font"] as! Font
                font.path = path
            }
            self.delegate.dataManager.recordDirectories(mainDirectory: folderPath, subDirectory: subdirectory, font: font)
            self.delegate.dataManager.saveContext()
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

