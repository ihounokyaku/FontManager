//
//  FontFolder+CoreDataProperties.swift
//  FontManager
//
//  Created by Dylan Southard on 2018/02/21.
//  Copyright © 2018年 Dylan Southard. All rights reserved.
//
//

import Foundation
import CoreData


extension FontFolder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FontFolder> {
        return NSFetchRequest<FontFolder>(entityName: "FontFolder")
    }

    @NSManaged public var isMainFolder: Bool
    @NSManaged public var name: String?
    @NSManaged public var path: String?
    @NSManaged public var fonts: NSSet?
    @NSManaged public var subFolders: NSSet?

}

// MARK: Generated accessors for fonts
extension FontFolder {

    @objc(addFontsObject:)
    @NSManaged public func addToFonts(_ value: Font)

    @objc(removeFontsObject:)
    @NSManaged public func removeFromFonts(_ value: Font)

    @objc(addFonts:)
    @NSManaged public func addToFonts(_ values: NSSet)

    @objc(removeFonts:)
    @NSManaged public func removeFromFonts(_ values: NSSet)

}

// MARK: Generated accessors for subFolders
extension FontFolder {

    @objc(addSubFoldersObject:)
    @NSManaged public func addToSubFolders(_ value: FontFolder)

    @objc(removeSubFoldersObject:)
    @NSManaged public func removeFromSubFolders(_ value: FontFolder)

    @objc(addSubFolders:)
    @NSManaged public func addToSubFolders(_ values: NSSet)

    @objc(removeSubFolders:)
    @NSManaged public func removeFromSubFolders(_ values: NSSet)

}
