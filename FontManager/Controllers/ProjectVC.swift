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
    let dataManager = CoreDataManager()
    var installer = FontInstaller()
    
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
        let alert = NewProjectPopup()
        let response: NSApplication.ModalResponse = alert.runModal()
        if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
            self.encoder.newProject(name: (alert.accessoryView as! NSTextField).stringValue, fonts: nil)
            self.reloadAllTables()
        }
    }
    
    func removeProject() {
        let alert = ConfirmationAlert(title: "Delete Project?", detail: "Nooo Backsies!")
        let res = alert.runModal()
        if res == NSApplication.ModalResponse.alertFirstButtonReturn {
            self.encoder.projectArray.remove(at: self.projectsTable.selectedRow)
            self.encoder.saveProjects()
            self.reloadAllTables()
        }
    }
    
    func importProject() {
        
        let path = FileManagement().savedPathOrDocDirectory(path: "importPath")
        let panelController = FilePanel(message: "Please choose a project files", path: path, fileTypes: ["fproj"])
        let panel = panelController.panel
        panel.beginSheetModal(for: self.view.window!, completionHandler: {(response) -> Void in
            if response != .cancel{
                if let error = self.encoder.importProject(from: panel.url!){
                    self.errorAlert("Error Importing Project", detail: error)
                } else {
                    self.reloadAllTables()
                }
            }
        })
    }
    
    func exportProject() {
        
        let project = self.encoder.projectArray[self.projectsTable.selectedRow]
        
        // ---- GET URL FOR EXPORT
        var path = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first)!.path
        if let url = UserDefaults.standard.value(forKey: "exportPath") as? String {
            path = url
        }
        
        //  ----SET UP AND DISPLAY PANEL
        let panelController = SavePanel(message: "Please select a folder", url: path, checkBoxTitle:"Export font files as well")
        let panel = panelController.panel
        panel.allowedFileTypes = ["fproj"]
        panel.beginSheetModal(for: self.view.window!, completionHandler: {(response) -> Void in
            if response != .cancel{
                
                //--get and save path
                path = panel.url!.path
                UserDefaults.standard.set(panel.url!.deletingLastPathComponent().path, forKey: "exportPath")
                print(path)
                
                //--save project file
                if let error = self.encoder.export(project: project, to: path) {
                    self.errorAlert("Error'd", detail: error)
                    return
                }
                
                //---save font files
                if panelController.checkedButton?.state == .on {
                    
                    //---Create Directory
                    let folderURL = panel.url!.deletingPathExtension()
                    let manager = FileManagement()
                    manager.createFolder(atPath: folderURL.path)
                    
                    //---Get and copy font files
                    let fonts = self.getFontFilesFor(project: project)
                    var errors = [String]()
                    for font in fonts {
                        let fontURL = URL(fileURLWithPath: font.path!)
                        if let error = manager.copyFile(fontURL, to: folderURL.path) {
                            errors.append(fontURL.lastPathComponent + error)
                        }
                    }
                    if errors.count > 0 {
                        self.errorFromArray(title: "Encountered the following errors:", errors: errors)
                    }
                    
                }
            }
        })
    }
    
    
    
    
    //MARK: - FONT FUNCTIONS
    func addFont() {
        //TODO: CreateFontPickerViewController
    }
    
    func removeFontFromProject() {
        
    }
    
    func installFonts() {
        
    }
    
    func uninstallFonts() {
        
    }
    
    //MARK: - FONT FUNCTIONS
    func getFontFilesFor(project:Project)->[Font] {
        var fonts = [Font]()
        for fontName in project.fonts {
            if let fontFile = self.dataManager.objectInCoreData(entityName: "Font", attribute: "name", name: fontName) as? Font{
                fonts.append(fontFile)
            }
        }
        return fonts
    }
    
    //MARK: - ERROR ALERTS, ETC
    
    //TODO: Refactor copied code
    func errorAlert(_ title:String, detail:String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = detail
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    func errorFromArray(title:String, errors:[String]) {
        if errors.count > 0 {
            var errorString = ""
            for error in errors {
                errorString += error + "\n"
            }
            self.errorAlert(title, detail: errorString)
        }
    }
    
}

//MARK: - TABLEVIEW DELEGATES/DATASOURCES

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
            let fontName = self.encoder.projectArray[self.projectsTable.selectedRow].fonts[row]
            cell.textField!.stringValue = fontName
            
            if let cdFont = self.dataManager.objectInCoreData(entityName: "Font", attribute: "name", name: fontName) as? Font {
                if self.installer.fontsInstalled(fonts: [cdFont],verbose:true) {
                    
                    cell.textField!.textColor = NSColor.green
                } else if !FileManager.default.fileExists(atPath: cdFont.path!) {
                    cell.textField!.textColor = NSColor.red
                }
            } else {
                cell.textField!.textColor = NSColor.red
                cell.textField!.font  = NSFont(name: "HelveticaNeue-Italic", size: 12)!
            }
        }
        
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if (notification.object as? NSTableView) == self.projectsTable {
            self.fontTable.reloadData()
        }
        self.toggleButtons()
    }
    
    func reloadAllTables() {
        self.projectsTable.reloadData()
        self.fontTable.reloadData()
    }
}
