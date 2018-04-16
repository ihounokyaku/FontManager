//
//  FontPickerVC.swift
//  FontManager
//
//  Created by Dylan Southard on 2018/04/16.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Cocoa

class FontPickerVC: NSViewController {
    
    
    @IBOutlet weak var segmentControl: NSSegmentedControl!
    @IBOutlet weak var outlineView: NSOutlineView!
    
    var allFamilies = [FontFamily]()
    var fontsInProject = [Font]()
    var delegate:ProjectVC!
    var fileManagement = FileManagement()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.outlineView.delegate = self
        self.outlineView.dataSource = self
        
        //---get fonts
        let dataManager = CoreDataManager()
        self.allFamilies = dataManager.allFamilies().sorted(by: { $0.name!.lowercased() < $1.name!.lowercased()})
        // Do view setup here.
        
        self.outlineView.reloadData()
    }
    
    func toggleButtons() {
        self.segmentControl.setEnabled(self.outlineView.selectedRowIndexes.count > 0, forSegment: 1)
    }
    
    //MARK: - Deal with Segments
    
    @IBAction func segmentButtonPressed(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 1 {
            
            //---get names for selected fonts
            let fontNames = self.selectedFonts().map{return $0.name!}
            
            //---get font list for project
            var fontsForProject = self.delegate.encoder.projectArray[self.delegate.projectsTable.selectedRow].fonts
            
            //---add fonts to fontlist that are not already added
            for fontName in fontNames {
                if !fontsForProject.contains(fontName) {
                    fontsForProject.append(fontName)
                }
            }
            
            //---replace fontlist and save
            self.delegate.encoder.projectArray[self.delegate.projectsTable.selectedRow].fonts = fontsForProject.sorted(by:{$0.lowercased() < $1.lowercased()})
            self.delegate.encoder.saveProjects()
            
            //---reload ProjectViewdData
            self.delegate.fontTable.reloadData()
        }
        self.dismiss(self)
    }
    
    func selectedFonts()-> [Font] {
        var fontsSelected = [Font]()
        for row in Array(self.outlineView.selectedRowIndexes) {
            if let item = self.outlineView.item(atRow: row) as? FontFamily {
                
                fontsSelected += Array(item.fonts!) as! [Font]
                
            } else if let item = self.outlineView.item(atRow: row) as? Font {
                fontsSelected.append(item)
            }
        }
        return fontsSelected
    }
    
}

extension FontPickerVC : NSOutlineViewDelegate, NSOutlineViewDataSource {
    
    //MARK: - OUTLINE DATASOURCE METHODS
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let family = item as? FontFamily {
            return family.fonts!.count
        }
        return self.allFamilies.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let family = item as? FontFamily {
            let fonts = (Array(family.fonts!) as! [Font]).sorted(by: { $0.name!.lowercased() < $1.name!.lowercased()})
            return fonts[index]
        }
        return self.allFamilies[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
            if let family = item as? FontFamily {
                return family.fonts!.count > 1
            }
        return false
    }
    
    //MARK: - OUTLINE DELEGATE METHODS
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let view = outlineView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? SelectableCell
        if let textField = view?.textField {
            var installed = false
            var missing = false
            var alreadyAdded = false
            
            if let family = item as? FontFamily {
                let fonts = Array(family.fonts!) as! [Font]
                if fonts.count == 1 {
                    let font = fonts[0]
                    textField.stringValue = font.name!
                    if self.fontsInProject.contains(font) {
                        alreadyAdded = true
                    }
                } else {
                    textField.stringValue = family.name!
                }
                installed = self.delegate.installer.fontsInstalled(fonts: fonts)
                missing = self.fileManagement.fontsMissing(fonts: fonts)
            } else if let font = item as? Font{
                
                textField.stringValue = "---" + font.name!.lastSection()
                if self.fontsInProject.contains(font) {
                    alreadyAdded = true
                } else {
                    installed = self.delegate.installer.fontsInstalled(fonts: [font])
                    missing = self.fileManagement.fontsMissing(fonts: [font])
                }
                
            }
            
            //Text Color
            if installed {
                textField.textColor = NSColor.systemGreen
            } else if missing {
                textField.textColor = NSColor.red
            } else {
                textField.textColor = NSColor.black
            }
            
            if alreadyAdded {
                textField.textColor = NSColor.gray
                textField.font  = NSFont(name: "HelveticaNeue-Italic", size: textField.font!.pointSize)!
            }
            
            view?.selectable = !alreadyAdded
        }
        
        return view
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        if let view = outlineView.view(atColumn: 0, row: outlineView.row(forItem: item), makeIfNecessary: false) as? SelectableCell, view.selectable == false {
                return false
        }
        return true
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        self.toggleButtons()
    }
    
    
}
