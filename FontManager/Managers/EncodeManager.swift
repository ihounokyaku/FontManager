//
//  EncodeManager.swift
//  FontManager
//
//  Created by Dylan Southard on 2018/04/14.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Cocoa

class EncodeManager: NSObject {
    var exampleArray = [ExampleText]()
    var dataFilePath = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
    
    override init() {
        super.init()
        self.loadExamples()
    }
    
    func saveExamples() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(self.exampleArray)
            try data.write(to:dataFilePath!.appendingPathComponent("ExampleText.plist"))
            print(self.dataFilePath!)
        } catch {
            print(error)
        }
    }
    
    func loadExamples() {
        if let data = try? Data(contentsOf:dataFilePath!.appendingPathComponent("ExampleText.plist")) {
            let decoder = PropertyListDecoder()
            do {
               self.exampleArray = try decoder.decode([ExampleText].self, from: data)
            } catch {
                print("error decoding text \(error)")
            }
        }
    }
    
    
}
