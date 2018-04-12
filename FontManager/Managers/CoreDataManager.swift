//
//  CoreDataManager.swift
//  FontManager
//
//  Created by Dylan Southard on 2018/02/16.
//  Copyright © 2018年 Dylan Southard. All rights reserved.
//

import Cocoa
import CoreData

class CoreDataManager: NSObject {
    var tempFont:Font?
    
    var delegate:ViewController!
    let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    func objectInCoreData(entityName:String, attribute:String, name:String)-> NSManagedObject? {
        if let objects = self.objectsInCoreData(entityName: entityName, attribute: attribute, name: name) {
            if objects.count > 0 {
                return objects[0]
            }
        }
        return nil
    }
    
    func objectsInCoreData(entityName:String, attribute:String, name:CVarArg)-> [NSManagedObject]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: attribute + " == %@", name)
        do {
            let matches = try self.context.fetch(fetchRequest) as! [NSManagedObject]
            if matches.count > 0 {
                return matches
            }
        } catch let error as NSError {
            self.delegate.errorAlert("Error with Fetch Request!", detail: "\(error)")
        }
        return nil
    }
    
    func newFont(fontFile:NSFont, path:String)-> Font {
        let font = NSEntityDescription.insertNewObject(forEntityName: "Font", into: self.context) as! Font
        font.name = fontFile.fontName
        font.path = path
        font.familyName = fontFile.familyName
        //get font family
        if let family = self.objectInCoreData(entityName: "FontFamily", attribute:"name", name: fontFile.familyName!) as? FontFamily {
            font.family = family
        } else {
            let family = NSEntityDescription.insertNewObject(forEntityName: "FontFamily", into: self.context) as! FontFamily
            family.name = font.familyName
            font.family = family
        }
        
        //add Language Tags
        self.tagLanguages(fontFile: fontFile, font: font, languages: ["English", "日本語", "ไทย"])
        font.fileName = URL(fileURLWithPath: path).deletingPathExtension().lastPathComponent
        self.saveContext()
        return font
    }
    
    func recordDirectories(mainDirectory:String, subDirectory:String?, font:Font) {
        let mainFolder = self.coreDataDirectory(path: mainDirectory)
        mainFolder.isMainFolder = true
        var directories = [FontFolder]()
        if let sub = subDirectory {
            let subFolder = self.coreDataDirectory(path: sub)
            
            if !(mainFolder.subFolders?.contains(subFolder))! {
                mainFolder.addToSubFolders(subFolder)
            }
            directories.append(subFolder)
        }
        directories.append(mainFolder)
        font.directories = NSSet(array: directories)
        self.saveContext()
    }
    
    func coreDataDirectory(path:String)-> FontFolder {
        var directory:FontFolder!
        if let folder = self.objectInCoreData(entityName: "FontFolder", attribute: "path", name: path) as? FontFolder {
            directory = folder
        } else {
            directory = NSEntityDescription.insertNewObject(forEntityName: "FontFolder", into: self.context) as! FontFolder
            directory.path = path
            directory.name = URL(fileURLWithPath: path).lastPathComponent
        }
        return directory
    }
    
    func tagLanguages(fontFile:NSFont, font:Font, languages:[String]) {
        for language in languages {
            let scalar = language.unicodeScalars.first!
            if scalar.isIn(font: fontFile) {
                self.addTag(name: language, type: "Language", fonts: [font])
            }
        }
    }
    
    func addTag(name:String, type:String, fonts:[Font]) {
        var tag:Tag!
        
        if let newTag = self.objectInCoreData(entityName: "Tag", attribute:"name", name: name) as? Tag {
            tag = newTag
        } else {
            tag = NSEntityDescription.insertNewObject(forEntityName: "Tag", into: self.context) as! Tag
            tag.name = name
            tag.type = type
        }
        
        for font in fonts {
            if !font.tags!.contains(tag) {
                font.addToTags(tag)
            }
        }
        self.saveContext()
    }
    
    func removeTag(tag:Tag, fonts:[Font]) {
        for font in fonts {
            font.removeFromTags(tag)
            if tag.fonts!.count == 0 {
                self.context.delete(tag)
                self.saveContext()
            }
        }
    }
    
    
    func saveContext(){
        do {
            try self.context.save()
        } catch {
            self.delegate.errorAlert("Error Saving", detail: "\(error)")
        }
    }
    
    func allFonts()-> [Font] {
        var fonts = [Font]()
        do {
       try fonts = self.context.fetch(Font.fetchRequest())
        } catch {
            self.delegate.errorAlert("Error Retrieving Fonts!", detail: "\(error)")
        }
        return fonts
    }
    
    func allFamilies()-> [FontFamily] {
        var families = [FontFamily]()
        do {
            try families = self.context.fetch(FontFamily.fetchRequest())
        } catch {
            self.delegate.errorAlert("Error Retrieving Font Families!", detail: "\(error)")
        }
        return families
    }
    
    func allMainDirectories()-> [FontFolder] {
        if let dirs = self.objectsInCoreData(entityName: "FontFolder", attribute: "isMainFolder", name: true as CVarArg) as? [FontFolder]{
            return dirs
        }
        return [FontFolder]().sorted(by: { $0.name!.lowercased() < $1.name!.lowercased() })
    }
    
    func allTags()-> [Tag] {
        var tags = [Tag]()
        do {
            try tags = self.context.fetch(Tag.fetchRequest())
        } catch {
            self.delegate.errorAlert("Error Retrieving Tags!", detail: "\(error)")
        }
        return tags.sorted(by: {$0.name!.lowercased() < $1.name!.lowercased()})
    }
    
    func deleteFont(_ font:Font) {
        let tags = Array(font.tags!) as! [Tag]
        let directories = Array(font.directories!) as! [FontFolder]
        let family = font.family!
        self.context.delete(font)
        self.saveContext()
        
        //=== delete empty directories
        for directory in directories {
            if directory.fonts!.count == 0 {
                self.context.delete(directory)
            }
        }
        
        //----Delete unused tags
        for tag in tags {
            if tag.fonts!.count == 0 {
                self.context.delete(tag)
            }
        }
        
        //---Delete empty family
        if family.fonts!.count == 0 {
            print("no fonts in family")
            self.context.delete(family)
        } else {
            print("\(family.fonts!.count) fonts in family")
        }
        
        self.saveContext()
    }
}
