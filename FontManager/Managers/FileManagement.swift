//
//  FileManager.swift
//  FontManager
//
//  Created by Dylan Southard on 2018/04/16.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Cocoa

class FileManagement: NSObject {

    func copyFile (_ fileUrl:URL, to:String)-> String? {
        let fileName = fileUrl.lastPathComponent
        do {
            try FileManager.default.copyItem(at: fileUrl, to: URL(fileURLWithPath: to + "/" + fileName))
            return nil
        } catch let error as NSError{
            return error.localizedDescription
        }
    }
    
    func createFolder(atPath filePath:String) {
        do {
            try FileManager.default.createDirectory(atPath:filePath , withIntermediateDirectories: false, attributes: nil)
        } catch let error as NSError{
            print("could not create directory ÷\(error)")
        }
    }
    
    func savedPathOrDocDirectory(path:String)-> String {
        var path = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first)!.path
        if let url = UserDefaults.standard.value(forKey: path) as? String {
            path = url
        }
        return path
    }
}
