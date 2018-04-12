//
//  FontFamily+CoreDataProperties.swift
//  FontManager
//
//  Created by Dylan Southard on 2018/02/20.
//  Copyright © 2018年 Dylan Southard. All rights reserved.
//
//

import Foundation
import CoreData


extension FontFamily {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FontFamily> {
        return NSFetchRequest<FontFamily>(entityName: "FontFamily")
    }

    @NSManaged public var name: String?
    @NSManaged public var fonts: NSSet?
    @NSManaged public var tags: NSSet?

}

// MARK: Generated accessors for fonts
extension FontFamily {

    @objc(addFontsObject:)
    @NSManaged public func addToFonts(_ value: Font)

    @objc(removeFontsObject:)
    @NSManaged public func removeFromFonts(_ value: Font)

    @objc(addFonts:)
    @NSManaged public func addToFonts(_ values: NSSet)

    @objc(removeFonts:)
    @NSManaged public func removeFromFonts(_ values: NSSet)

}

// MARK: Generated accessors for tags
extension FontFamily {

    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)

}
