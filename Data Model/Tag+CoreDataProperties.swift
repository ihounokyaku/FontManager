//
//  Tag+CoreDataProperties.swift
//  FontManager
//
//  Created by Dylan Southard on 2018/02/20.
//  Copyright © 2018年 Dylan Southard. All rights reserved.
//
//

import Foundation
import CoreData


extension Tag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }

    @NSManaged public var name: String?
    @NSManaged public var type: String?
    @NSManaged public var fontFamilies: NSSet?
    @NSManaged public var fonts: NSSet?

}

// MARK: Generated accessors for fontFamilies
extension Tag {

    @objc(addFontFamiliesObject:)
    @NSManaged public func addToFontFamilies(_ value: FontFamily)

    @objc(removeFontFamiliesObject:)
    @NSManaged public func removeFromFontFamilies(_ value: FontFamily)

    @objc(addFontFamilies:)
    @NSManaged public func addToFontFamilies(_ values: NSSet)

    @objc(removeFontFamilies:)
    @NSManaged public func removeFromFontFamilies(_ values: NSSet)

}

// MARK: Generated accessors for fonts
extension Tag {

    @objc(addFontsObject:)
    @NSManaged public func addToFonts(_ value: Font)

    @objc(removeFontsObject:)
    @NSManaged public func removeFromFonts(_ value: Font)

    @objc(addFonts:)
    @NSManaged public func addToFonts(_ values: NSSet)

    @objc(removeFonts:)
    @NSManaged public func removeFromFonts(_ values: NSSet)

}
