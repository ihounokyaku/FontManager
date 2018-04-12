//
//  Font+CoreDataProperties.swift
//  FontManager
//
//  Created by Dylan Southard on 2018/02/21.
//  Copyright © 2018年 Dylan Southard. All rights reserved.
//
//

import Foundation
import CoreData


extension Font {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Font> {
        return NSFetchRequest<Font>(entityName: "Font")
    }

    @NSManaged public var familyName: String?
    @NSManaged public var fileName: String?
    @NSManaged public var name: String?
    @NSManaged public var path: String?
    @NSManaged public var family: FontFamily?
    @NSManaged public var tags: NSSet?
    @NSManaged public var directories: NSSet?

}

// MARK: Generated accessors for tags
extension Font {

    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)

}

// MARK: Generated accessors for directories
extension Font {

    @objc(addDirectoriesObject:)
    @NSManaged public func addToDirectories(_ value: FontFolder)

    @objc(removeDirectoriesObject:)
    @NSManaged public func removeFromDirectories(_ value: FontFolder)

    @objc(addDirectories:)
    @NSManaged public func addToDirectories(_ values: NSSet)

    @objc(removeDirectories:)
    @NSManaged public func removeFromDirectories(_ values: NSSet)

}
