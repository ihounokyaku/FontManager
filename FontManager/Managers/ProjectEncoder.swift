//
//  EncodeManager.swift
//  FontManager
//
//  Created by Dylan Southard on 2018/04/14.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Cocoa

class ProjectEncoder: NSObject {
    var projectArray = [Project]()
    var dataFilePath = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
    
    override init() {
        super.init()
        self.loadProjects()
    }
    
    func saveProjects() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(self.projectArray)
            try data.write(to:dataFilePath!.appendingPathComponent("Projects.plist"))
            print(self.dataFilePath!)
        } catch {
            print(error)
        }
    }
    
    func loadProjects() {
        if let data = try? Data(contentsOf:dataFilePath!.appendingPathComponent("Projects.plist")) {
            let decoder = PropertyListDecoder()
            do {
               self.projectArray = try decoder.decode([Project].self, from: data)
            } catch {
                print("error decoding text \(error)")
            }
        }
    }
    
    func newProject(name:String, fonts:[String]?) {
        if name != "" {
            let project = Project(name:name)
            if let fontArray = fonts {
                project.fonts = fontArray
            }
            self.projectArray.append(project)
            self.saveProjects()
        }
    }
    
    func export(project:Project, to path:String)->String? {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(project)
            try data.write(to:URL(fileURLWithPath: path))
            return nil
        } catch {
            return error.localizedDescription
        }
    }
    
    func importProject(from url:URL)-> String? {

            do {
                let data = try Data(contentsOf:url)
                let decoder = PropertyListDecoder()
                self.projectArray.append(try decoder.decode(Project.self, from: data))
                self.saveProjects()
                return nil
            } catch {
                return error.localizedDescription
            }
    }

    
    
    
}
