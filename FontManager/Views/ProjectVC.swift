//
//  ProjectVC.swift
//  FontManager
//
//  Created by Dylan Southard on 2018/04/15.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Cocoa

class ProjectVC: NSViewController {
    //MARK: - DATA MODEL/ENCODER
    let encoder = ProjectEncoder()
    
    
    //MARK: - IBOutlets
    // -- TableViews
    @IBOutlet weak var projectsTable: NSTableView!
    @IBOutlet weak var fontTable: NSTableView!
    
    // --- Segment Views
    @IBOutlet weak var addRemoveProjectsSegment: NSSegmentedControl!
    @IBOutlet weak var addRemoveFontsSegment: NSSegmentedControl!
    
    @IBOutlet weak var importExportProjectSegment: NSSegmentedControl!
    @IBOutlet weak var importRemoveFontsSegment: NSSegmentedControl!
    
    //MARK: - SET VIEW
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //-- Set delegates
        self.projectsTable.delegate = self
        self.projectsTable.dataSource = self
        self.fontTable.delegate = self
        self.fontTable.dataSource = self
        
        //-- Set View
        self.toggleButtons()
    }
    
    //MARK: - Handle Enable/Disable
    func toggleButtons()  {
        self.addRemoveProjectsSegment.setEnabled((self.projectsTable.selectedRow >= 0), forSegment: 1)
        self.importExportProjectSegment.setEnabled(self.projectsTable.selectedRow >= 0, forSegment: 1)
        self.addRemoveFontsSegment.setEnabled(self.fontTable.selectedRow >= 0, forSegment: 1)
        self.importRemoveFontsSegment.setEnabled(self.fontTable.selectedRow >= 0, forSegment: 1)
    }
    
    
    //MARK: - HANDLE BUTTON ACTIONS
    
    @IBAction func projectsAddRemovePressed(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            self.addProject()
        } else {
            self.removeProject()
        }
    }
    
    @IBAction func projectsImportExportPressed(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            self.importProject()
        } else {
            self.exportProject()
        }
    }
    
    @IBAction func fontsAddRemovePressed(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            self.addFont()
        } else {
            self.removeFontFromProject()
        }
    }
    
    @IBAction func fontsImportExportPressed(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            self.installFonts()
        } else {
            self.uninstallFonts()
        }
    }
    
    //MARK: - PROJECT FUNCTIONS
    func addProject() {
        //TODO: Add Project
        
    }
    
    func removeProject() {
        //TODO: Remove Project
    }
    
    func importProject() {
        //TODO: Import Project
    }
    
    func exportProject() {
        
    }
    
    //MARK: - FONT FUNCTIONS
    func addFont() {
        
    }
    
    func removeFontFromProject() {
        
    }
    
    func installFonts() {
        
    }
    
    func uninstallFonts() {
        
    }
    
}

extension ProjectVC : NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == self.projectsTable {
            return self.encoder.projectArray.count
        } else if tableView == self.fontTable && self.projectsTable.selectedRow >= 0{
            return self.encoder.projectArray[self.projectsTable.selectedRow].fonts.count
        }
        return 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        
        if tableView == self.projectsTable {
            cell.textField!.stringValue = self.encoder.projectArray[row].name
        } else if tableView == self.fontTable {
            cell.textField!.stringValue = self.encoder.projectArray[self.projectsTable.selectedRow].fonts[row]
            //TODO: Check if installed and exists
        }
        
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if (notification.object as? NSTableView) == self.projectsTable {
            self.fontTable.reloadData()
        }
        self.toggleButtons()
    }
}
