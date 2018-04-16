//
//  FileManagement.swift
//  FontManager
//
//  Created by Dylan Southard on 2018/02/24.
//  Copyright © 2018年 Dylan Southard. All rights reserved.
//

import Cocoa

class FontInstaller: NSObject {
    var delegate:ViewController!
    var fontFolderPath = ""
    var installedFonts = [String]()

    //MARK: ============== SET MAIN DIRECTORY==============================
    
    func setFontDirectory() {
        if let folderURL = UserDefaults.standard.value(forKey: "fontFolderURL") as? String {
            self.fontFolderPath = folderURL
        } else {
            let homeDirectory = NSHomeDirectory()
            let fontD = homeDirectory + "/Library/Fonts/"
            let fontDURL = URL(string:fontD)!
            if fontDURL.hasDirectoryPath {
                self.fontFolderPath = fontD
                UserDefaults.standard.setValue(fontDURL.path, forKey: "fontFolderURL")
            } else {
                self.chooseSystemFontDirectory(true)
            }
        }
        
    }
    
    func chooseSystemFontDirectory(_ loop:Bool = false) {
        let panel = self.delegate.directoryPanel(message: "Please select your font folder", url: self.fontFolderPath)
        panel.beginSheetModal(for: delegate.view.window!, completionHandler: {(response) -> Void in
            if response == .cancel{
                if loop {
                    self.chooseSystemFontDirectory(true)
                }
            } else {
                UserDefaults.standard.setValue(panel.url!.path, forKey: "fontFolderURL")
                self.fontFolderPath = panel.url!.path
                self.getInstalledFonts()
            }
        })
    }
    func chooseFontDirectory(_ loop:Bool = false) {
    }

//==================GET INSTALLED=======================
    
    func getInstalledFonts() {
        print("getting installed")
        let fontFolderURL = URL(fileURLWithPath: self.fontFolderPath)
        if fontFolderURL.hasDirectoryPath {
            let (fontsInstalled,_ ) = self.delegate.importer.getFontFiles(folderUrl: fontFolderURL)
            self.installedFonts = fontsInstalled.map { return $0.lastPathComponent }
            self.installedFonts = self.installedFonts.sorted(by: { $0.lowercased() < $1.lowercased() })
        } else {
            print("fontFolder does not have directory fontFolder is: \(fontFolderURL.path)")
        }
        self.delegate.installedFontsTable.reloadData()
    }
    
    
//==================INSTALL==============================
    
    func installFonts(fonts:[Font]) {
        var errors = [String]()
        for font in fonts {
            let fontURL = URL(fileURLWithPath: font.path!)
            if fontURL.isFileURL {
                if let copyError = self.copyFile(fontURL) {
                    errors.append(font.name! + "\n---" + copyError)
                }
            } else {
                errors.append(font.name!)
            }
        }
        self.delegate.errorFromArray(title: "Could not install the following files:", errors: errors)
        self.getInstalledFonts()
        self.delegate.reloadAll()
    }
    
    func copyFile(_ fileURL:URL)-> String?  {
        let fileName = fileURL.lastPathComponent
        do {
            try FileManager.default.copyItem(at: fileURL, to: URL(fileURLWithPath: self.fontFolderPath + "/" + fileName))
            return nil
        } catch let error as NSError{
            
            return error.localizedDescription
        }
    }
    
    
    
//==================REMOVE==============================
    func removeFonts(fonts:[Font]) {
        var errors = [String]()
        if self.delegate.fontsMissing(fonts: fonts, true) {
            if !self.delegate.confirmed("Some Fonts are Missing", detail: "Some of the fonts you are attempting to remove cannot be found in their original folder. If you remove these fonts they may be gone forever!") {
                return
            }
        }
        for font in fonts {
            if let deleteError = self.removeFile(font: font) {
                errors.append(font.name! + "\n---" + deleteError)
            }
        }
        self.delegate.errorFromArray(title: "Could not remove the following files:", errors: errors)
        self.getInstalledFonts()
        self.delegate.reloadAll()
    }
    
    
    func removeFile(font:Font)-> String? {
        let fileName = URL(fileURLWithPath: font.path!).lastPathComponent
        do {
            try FileManager.default.removeItem(at: URL(fileURLWithPath: self.fontFolderPath + "/" + fileName))
            return nil
        } catch let error as NSError{
            return error.localizedDescription
        }
    }

    
//================= CHECK FOR INSTALLED =========================
    
    func fontsInstalled(fonts:[Font], any:Bool = false, verbose:Bool = false)-> Bool {
        for font in fonts {
           
            if let fileName = font.fileName {
                let installedNames = self.installedFonts.map{return $0.withoutFileExtension()}
                if installedNames.contains(fileName) == any {
                    return any
                }
            }
        }
        return !any
    }
    

    
}
