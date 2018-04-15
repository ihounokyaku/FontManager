//
//  Project.swift
//  
//
//  Created by Dylan Southard on 2018/04/15.
//

import Foundation

class Project : Codable {
    
    var name:String = ""
    var fonts = [String]()
    
    init(name:String) {
        self.name = name
    }
}
