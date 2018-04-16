//
//  ViewController.swift
//  FontManager
//
//  Created by Dylan Southard on 15/2/18.
//  Copyright © ค.ศ. 2018 Dylan Southard. All rights reserved.
//

import Cocoa
import CoreText
import AyLoading


class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate {

    @IBOutlet weak var folderTree: NSOutlineView!
    @IBOutlet weak var outlineView: NSOutlineView!
    @IBOutlet weak var installedFontsTable: NSTableView!
    @IBOutlet weak var tagTable: NSTableView!
    @IBOutlet weak var singleTagTable: NSTableView!
    @IBOutlet weak var tagAdder: NSTextField!
    @IBOutlet weak var otherOptionsTable: NSTableView!
    @IBOutlet weak var characterFilterBox: NSTextField!
    
    @IBOutlet weak var refreshButton: NSButton!
    
    @IBOutlet weak var dragClip: DraggableClip!
    @IBOutlet weak var addFolderButton: NSButton!
    @IBOutlet weak var removeFolder: NSButton!
    @IBOutlet weak var removeButton: NSButton!
    @IBOutlet weak var addTagButton: NSButton!
    @IBOutlet weak var newProjectButton: NSButton!
    @IBOutlet weak var viewProjects: NSButton!
    @IBOutlet weak var addToProjectButton: NSButton!
    
    @IBOutlet weak var clearAllTagSelection: NSButton!
    @IBOutlet weak var deleteAllTagSelection: NSButton!
    @IBOutlet weak var clearFontTagSelection: NSButton!
    @IBOutlet weak var deleteFontTagSelection: NSButton!
    
    @IBOutlet weak var installButton: NSButton!
    @IBOutlet var fontDisplay: NSTextView!
    @IBOutlet weak var statusLabel: NSTextField!

    @IBOutlet weak var exampleSegment: NSSegmentedControl!
    
    var allTables = [NSTableView]()
    var allButtons = [NSButton]()
    var allTextFields = [NSTextField]()
    
    //=================== Managers==========================
    let installer = FontInstaller()
    let importer = FontImporter()
    let dataManager = CoreDataManager()
    
    
    
//===================DISPLAY ARRAYS=====================
    
    var fontsDisplayed = [FontFamily:[Font]]()
    var familyKeys = [FontFamily]()
    
//===================OTHER VARS=========================
    var selectedFolderURL:URL?
    var displayedFont = NSFont.systemFont(ofSize: 30)
    
    
    //MARK: ===================ON LOAD=============================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //-----Create Arrays---------
        self.allTables = [self.outlineView, self.folderTree, self.tagTable, self.singleTagTable, self.otherOptionsTable, self.installedFontsTable]
        self.allButtons = [self.removeFolder, self.removeButton, self.installButton, self.addFolderButton, self.clearAllTagSelection, self.clearFontTagSelection, self.deleteAllTagSelection, self.deleteFontTagSelection, self.addTagButton, self.refreshButton, self.newProjectButton, self.viewProjects, self.addToProjectButton]
        self.allTextFields = [self.characterFilterBox, self.tagAdder]
        
        //-----Assign Delegates-------
        for table in self.allTables {
            table.dataSource = self
            table.delegate = self
        }
        
        //-----Set Contextual Menus

        self.singleTagTable.menu = self.tableMenu(withDelegate: self.singleTagTable, andItems: [self.tableMenuItem(ofType: .remove)])
        self.tagTable.menu = self.tableMenu(withDelegate: self.tagTable, andItems: [self.tableMenuItem(ofType: .remove)])
        
        self.installedFontsTable.menu = self.tableMenu(withDelegate:self.installedFontsTable, andItems:[self.tableMenuItem(ofType: .showInFinder)])
        self.outlineView.menu = self.tableMenu(withDelegate: self.outlineView, andItems:[self.tableMenuItem(ofType: .showInFinder)])
        self.folderTree.menu = self.tableMenu(withDelegate: self.folderTree, andItems:[self.tableMenuItem(ofType: .showInFinder)])
        
        
        self.installer.delegate = self
        self.dataManager.delegate = self
        self.importer.delegate = self
        self.dragClip.delegate = self
        
        //--------Load stuff---------
        self.loadAllFamilies()
        self.reloadAll()
    }

    override func viewDidAppear() {
        
        super.viewDidAppear()
        self.installer.setFontDirectory()
        self.installer.getInstalledFonts()
    }
    
    
    //MARK: ====================== GET/SET FOLDERS ===================================
    
    
    func getAllFonts() {
        self.populateFontWindow()
        self.reloadAll()
    }
    
    @IBAction func reloadPressed(_ sender: Any) {
        let directories = self.dataManager.allMainDirectories().map{return URL(fileURLWithPath:$0.path!)}
        self.importer.importFilesFromDirectory(urls: directories)
        
    }
    
    
    //MARK: - ================DISPLAY STUFF =======================
    func fontsFromDirectories(_ directories:[FontFolder])-> [Font] {
        var fonts = [Font]()
        for directory in directories {
            let fontArray = Array(directory.fonts!) as! [Font]
            for font in fontArray {
                if !fonts.contains(font) {
                    fonts.append(font)
                }
            }
        }
        return fonts
    }
    
    func familyDictionary(fonts:[Font])-> ([FontFamily], [FontFamily:[Font]]) {
        var keys = [FontFamily]()
        var dic = [FontFamily:[Font]]()
        for font in fonts {
            if !keys.contains(font.family!) {
                //create entry
                dic[font.family!] = [font]
                keys.append(font.family!)
            } else {
                //add to existing entry if necessary
                if !dic[font.family!]!.contains(font) {
                  dic[font.family!]!.append(font)
                }
            }
        }
        return (keys.sorted(by: { $0.name!.lowercased() < $1.name!.lowercased() }), dic)
    }
    
    func populateFontWindow() {
        let selectedRows = Array(self.folderTree.selectedRowIndexes)
        if selectedRows.count == 0 {
           self.loadAllFamilies()
        } else {
            let directories = self.selectedDirectories()
            (self.familyKeys, self.fontsDisplayed) = self.familyDictionary(fonts: self.canDisplay(self.tagged(self.filterByOtherOptions(self.fontsFromDirectories(directories)))))
        }
       
        self.reloadFontView()
    }
    
    func selectedDirectories()->[FontFolder] {
        var directories = [FontFolder]()
        
        let selectedRows = Array(self.folderTree.selectedRowIndexes)
        if selectedRows.count == 0 {
            self.loadAllFamilies()
        } else {
            for row in selectedRows {
                if let directory = self.folderTree.item(atRow: row) as? FontFolder {
                    directories.append(directory)
                }
            }
    }
        return directories
    }
    
    func loadAllFamilies() {
        var allKeys = self.dataManager.allFamilies().sorted(by: { $0.name!.lowercased() < $1.name!.lowercased() })
        
        for family in allKeys {
            let displayableFonts = self.canDisplay(self.tagged(self.filterByOtherOptions(Array(family.fonts!) as! [Font])))
            if displayableFonts.count > 0 {
                self.fontsDisplayed[family] = displayableFonts
            } else {
                let index = allKeys.index(of: family)
                allKeys.remove(at: index!)
            }
        }
        self.familyKeys = allKeys
        self.reloadFontView()
    }
    
    func tagged(_ fonts:[Font])-> [Font] {
        var taggedFonts = [Font]()
        let selectedRows = (Array(self.tagTable.selectedRowIndexes) as [Int])
        if selectedRows.count == 0 {
            return fonts
        }
        for font in fonts {
            if self.fontTagged(font) {
                taggedFonts.append(font)
            }
        }
        return taggedFonts
    }
    
    func fontTagged(_ font:Font)-> Bool {
        let fontTags = (Array(font.tags!) as! [Tag])
        for tag in self.tagsSelected() {
            if !fontTags.contains(tag) {
                return false
            }
        }
        return true
    }
    
    func filterByOtherOptions(_ fonts:[Font])-> [Font]{
        var selectedFonts = [Font]()
        if self.otherOptionsTable.selectedRow < 1 {
            return fonts
        }
        for font in fonts {
            if self.fontConformsToOtherOptions(font: font) {
                selectedFonts.append(font)
            }
        }
        return selectedFonts
    }
    
    func canDisplay(_ fonts:[Font])-> [Font] {
        var filteredFonts = [Font]()
        if self.characterFilterBox.stringValue == "" {
            return fonts
        }
        for font in fonts {
            if font.canDisplayString(str: self.characterFilterBox.stringValue) {
                filteredFonts.append(font)
            }
        }
        return filteredFonts
    }
    
    func fontConformsToOtherOptions(font:Font)-> Bool {
        switch self.otherOptionsTable.selectedRow {
        case 1:
            return self.installer.installedFonts.contains(font.fileName!)
        case 2:
            return !self.installer.installedFonts.contains(font.fileName!)
        case 3:
            return !FileManager.default.fileExists(atPath: font.path!)
        case 4:
            return FileManager.default.fileExists(atPath: font.path!)
        default:
            return true
        }
    }
    
    func tagsSelected()-> [Tag] {
        var tags = [Tag]()
        let selectedRows = (Array(self.tagTable.selectedRowIndexes) as [Int])
        if selectedRows.count > 0 {
            for row in selectedRows {
                tags.append(self.dataManager.allTags()[row])
            }
        } else {
            tags = self.dataManager.allTags().sorted(by: { $0.name!.lowercased() < $1.name!.lowercased() })
        }
        return tags
    }
    
    //MARK: - ================INDIVIDUAL FONT STUFF ==============
    
    func tagsForSelected()-> [Tag] {
        var tags = [Tag]()
        var fonts = self.fontsSelected()
        
        if fonts.count > 0 {
            tags = Array(fonts[0].tags!) as! [Tag]
            fonts.remove(at: 0)
            for font in fonts {
                let fontTags = Array(font.tags!) as! [Tag]
                for tag in tags {
                    var index = 0
                    if !fontTags.contains(tag){
                        tags.remove(at: index)
                    }
                    index += 1
                }
            }
        }
        return tags.sorted(by: { $0.name!.lowercased() < $1.name!.lowercased() })
    }
    
    func fontsSelected()-> [Font] {
        var fonts = [Font]()
        let selectedRows = Array(self.outlineView.selectedRowIndexes)
        for row in selectedRows {
            if let family = self.outlineView.item(atRow: row) as? FontFamily {
                
                for font in self.fontsDisplayed[family]! {
                    if !fonts.contains(font){
                        fonts.append(font)
                    }
                }
            } else if let font = self.outlineView.item(atRow: row) as? Font {
                if !fonts.contains(font){
                    fonts.append(font)
                }
            }
        }
        return fonts
    }
    
    //MARK: - ================INSTALL/REMOVE FONT BUTTONS =======================
    
    @IBAction func installPressed(_ sender: Any) {
        self.installButton.isEnabled = false
        self.installer.installFonts(fonts: self.fontsSelected())
    }
    
    @IBAction func removePressed(_ sender: Any) {
        self.removeButton.isEnabled = false
        self.installer.removeFonts(fonts: self.fontsSelected())
    }
    
    
    
    
    //MARK: - =============== CHOOSE FONT DIRECTORY ======================
    
    @IBAction func directoryPressed(_ sender: Any) {
        self.installer.chooseSystemFontDirectory()
    }
    
    
    
    
    //MARK: - Text Example
    
    @IBAction func exampleSegmentPressed(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            
            self.presentVC(id: "ExampleTextEditor")
        } else if sender.selectedSegment == 1 {
            self.presentVC(id: "textExampleList")
        } else {
            self.fontDisplay.string = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
            UserDefaults.standard.set("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890", forKey: "fontDisplay")
        }
    }
    
    
    // MARK: - =================Present ViewController==============
    
    func presentVC(id:String) {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        var controller = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: id)) as! NSViewController
        if let textExampleVC = controller as? TextExampleVC {
            textExampleVC.delegate = self
            controller = textExampleVC
        } else if let view = controller as? EditTextVC {
            print(self.fontDisplay.string)
            view.str = self.fontDisplay.string
            controller = view
        } else if let addToProjectVC = controller as? AddToProjectVC {
           addToProjectVC.fonts = self.fontsSelected().map{return $0.name!}
        } else if let projectVC = controller as? ProjectVC {
            projectVC.installer = self.installer
        }
        self.presentViewControllerAsSheet(controller)
    }
    
    //MARK: - ===============PROJECT STUFF =================
    
    @IBAction func newProjectPressed(_ sender: Any) {
        let projectEncoder = ProjectEncoder()
        let projectName = self.newProjectAlert()
        if projectName != "" {
            let fontNames = self.fontsSelected().map{return $0.name!}
            projectEncoder.newProject(name: projectName, fonts: fontNames)
        }
    }
    
    @IBAction func addToExistingProjectPressed(_ sender: Any) {
        self.presentVC(id: "addToProjectVC")
    }
    
    @IBAction func viewProjectsPressed(_ sender: Any) {
        self.presentVC(id: "projectVC")
    }
    
    
    
    //MARK: - ================ TABLE DATA ==================
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == self.installedFontsTable {
            return self.installer.installedFonts.count
        } else if tableView == self.tagTable {
            return self.dataManager.allTags().count
        } else if tableView == self.singleTagTable {
            return self.tagsForSelected().count
        } else if tableView == self.otherOptionsTable {
            return 5
        }
        return 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! CustomCell
        
        if tableView == self.installedFontsTable {
            cell.textField!.stringValue = self.installer.installedFonts[row]
            
        } else if tableView == self.tagTable {
            cell.table = self.tagTable
            cell.fontTag = self.dataManager.allTags()[row]
            cell.textField!.stringValue = cell.fontTag!.name!
            NotificationCenter.default.addObserver(self, selector: #selector(textDidEndEditing(_:)), name: NSControl.textDidEndEditingNotification, object: cell.textField!)
        } else if tableView == self.singleTagTable {
                cell.fontTag = self.tagsForSelected()[row]
                cell.table = self.singleTagTable
            
                cell.textField!.stringValue = cell.fontTag!.name!
                NotificationCenter.default.addObserver(self, selector: #selector(textDidEndEditing(_:)), name: NSControl.textDidEndEditingNotification, object: cell.textField!)
        } else if tableView == self.otherOptionsTable {
            let text = ["All",  "Installed", "Not Installed","Missing", "Not Missing"]
            cell.textField!.stringValue = text[row]
        }
    
        return cell
    }
    
   
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let tableView = notification.object as! NSTableView
        if tableView == self.tagTable || tableView == self.otherOptionsTable {
            self.populateFontWindow()
        }
        self.toggleTagButtons()
    }
    
    func tableView(_ tableView: NSTableView, mouseDownInHeaderOf tableColumn: NSTableColumn) {
        tableView.deselectAll(self)
    }
    
    func textDidEndEditing(_ notification: Notification) {
        if let object = notification.object as? NSTextField {
        if let cell = object.superview as? CustomCell {
            if cell.table == self.singleTagTable {
                if cell.textField!.stringValue != cell.fontTag!.name! {
                    if cell.textField!.stringValue != "" {
                        self.dataManager.addTag(name: cell.textField!.stringValue, type: "User Tag", fonts: self.fontsSelected())
                    }
                    self.dataManager.removeTag(tag: cell.fontTag!, fonts: self.fontsSelected())
                }
            } else if cell.table == self.tagTable {
                if cell.textField!.stringValue != cell.fontTag!.name! {
                    if cell.textField!.stringValue != "" {
                        
                        self.dataManager.addTag(name: cell.textField!.stringValue, type: "User Tag", fonts: Array(cell.fontTag!.fonts!) as! [Font])
                        self.dataManager.removeTag(tag: cell.fontTag!, fonts: Array(cell.fontTag!.fonts!) as! [Font])
                    } else {
                        if self.confirmed("Delete Tag?", detail: "Are you sure you want to delete this tag? No backsies!") {
                            self.dataManager.removeTag(tag: cell.fontTag!, fonts: Array(cell.fontTag!.fonts!) as! [Font])
                        } else {
                            cell.textField!.stringValue = cell.fontTag!.name!
                        }
                    }
                }
            }
            NotificationCenter.default.removeObserver(self, name: NSControl.textDidEndEditingNotification, object: notification.object)
            self.singleTagTable.reloadData()
            self.tagTable.reloadData()
        }
        }
    }
    
   
    //MARK: - RELATED METHODS
    @IBAction func didEnterNewTag(_ sender: NSTextField) {
        if sender.stringValue != "" {
            self.dataManager.addTag(name: sender.stringValue, type: "User Tag", fonts: self.fontsSelected())
        }
        sender.stringValue = ""
        self.singleTagTable.reloadData()
        self.tagTable.reloadData()
    }
    
    @IBAction func didEnterFilterChars(_ sender: Any) {
        self.reloadAll()
    }
    
    
    @IBAction func clearSelectionPressed(_ sender: NSButton) {
        var table:NSTableView!
        if sender.tag == 3 {
            table = self.tagTable
        } else {
            table = self.singleTagTable
        }
        table.deselectAll(self)
    }
    
    
    @IBAction func deleteTagPressed(_ sender: NSButton) {
        var tagsToRemove = [Tag]()
        var delete = false
        var table:NSTableView!
        
        if sender.tag == 1 {
            table = self.tagTable
            delete = true
        } else {
            table = self.singleTagTable
        }
        let selected = Array(table.selectedRowIndexes)
        for i in selected {
            tagsToRemove.append((table.view(atColumn: 0, row: i, makeIfNecessary: false) as! CustomCell).fontTag!)
        }
        
        self.removeTags(tagsToRemove, delete:delete)
        
    }
    
    func removeTags(_ tags:[Tag], delete:Bool = false) {
        if !delete {
            for tag in tags {
                self.dataManager.removeTag(tag: tag, fonts: self.fontsSelected())
            }
            self.tagTable.reloadData()
            self.singleTagTable.reloadData()
        } else {
            if self.confirmed("Delete Tag?", detail: "Are you sure you want to delete these tags? No backsies!") {
                for tag in tags {
                    self.dataManager.removeTag(tag: tag, fonts: Array(tag.fonts!) as! [Font])
                }
                self.reloadAll()
            }
        }
    }
    
    

    //MARK: - =============== ADD/REMOVE FOLDERS ==========
    
    @IBAction func removeFolderPressed(_ sender: Any) {
        if self.confirmed("Remove this folder?", detail: "All font data it contains will be deleted from this manager (this will not affect the files on your hard disk)") {
            self.importer.removeFolders(self.selectedDirectories())
        }
    }
    
    @IBAction func newFolderPressed(_ sender: Any) {
        self.importer.chooseFontDirectory()
    }
    
    
    
    //MARK: - =============== ENABLE DISABLE ===============
    
    func enableDisableEverything(_ enable:Bool) {
        self.enableDisableControls(self.allButtons, enable)
        self.enableDisableControls(self.allTextFields, enable)
        self.enableDisableControls(self.allTables, enable)
        if enable == true {
            self.toggleRemove()
            self.toggleTagButtons()
            self.toggleInstallRemove()
            self.toggleProjectButtons()
        }
    }
    
    func enableDisableControls(_ controls:[NSControl], _ enable:Bool){
        for control in controls {
            control.isEnabled = enable
        }
    }
    
    
    func toggleRemove() {
        self.removeFolder.isEnabled = self.selectedDirectories().count > 0
        
    }
    
    func toggleTagButtons() {
        self.deleteFontTagSelection.isEnabled = self.singleTagTable.selectedRowIndexes.count > 0
        self.clearFontTagSelection.isEnabled = self.singleTagTable.selectedRowIndexes.count > 0
        self.deleteAllTagSelection.isEnabled = self.tagTable.selectedRowIndexes.count > 0
        self.clearAllTagSelection.isEnabled = self.tagTable.selectedRowIndexes.count > 0
    }
    
    func toggleProjectButtons() {
        self.newProjectButton.isEnabled = self.outlineView.selectedRowIndexes.count > 0
        self.addToProjectButton.isEnabled = self.outlineView.selectedRowIndexes.count > 0
    }
    
    func toggleInstallRemove() {
        let fonts = self.fontsSelected()
        if fonts.count != 0 && !self.fontsMissing(fonts: fonts){
            self.installButton.isEnabled = !self.installer.fontsInstalled(fonts: fonts)
            self.removeButton.isEnabled = self.installer.fontsInstalled(fonts: fonts, any:true)
        } else {
            self.installButton.isEnabled = false
            self.removeButton.isEnabled = false
        }
    }
    
    //MARK: - =============== ALERTS HANDLING =============
    func errorAlert(_ title:String, detail:String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = detail
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    func confirmed(_ title:String, detail:String)-> Bool {
            let alert = ConfirmationAlert(title: title, detail: detail)
            let res = alert.runModal()
            if res == NSApplication.ModalResponse.alertFirstButtonReturn {
                return true
            }
            return false
    }
    
    
    //TODO: Refactor copied code
    func errorFromArray(title:String, errors:[String]) {
        if errors.count > 0 {
            var errorString = ""
            for error in errors {
                errorString += error + "\n"
            }
            self.errorAlert(title, detail: errorString)
        }
    }
    
    func newProjectAlert()-> String {
        let alert = NewProjectPopup()
        let response: NSApplication.ModalResponse = alert.runModal()
        if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
            return (alert.accessoryView as! NSTextField).stringValue
        } else {
            return ""
        }
        
    }
//==============UPDATES=====================
    
    func reloadAll() {
        print("reloading all data")
        self.folderTree.reloadData()
        self.tagTable.reloadData()
        self.populateFontWindow()
        self.reloadFontView()
        self.installedFontsTable.reloadData()
    }
    
    
    //MARK: ================ CONTEXTUAL MENU =========================
    
    
    func tableMenuItem(ofType type:MenuItemType) -> NSMenuItem {
        switch type {
        case .remove:
            return NSMenuItem(title: "Remove", action: #selector(removeItem(_:)), keyEquivalent: "")
        case .showInFinder:
            return NSMenuItem(title: "Show in finder", action: #selector(showInFinderClicked(_:)), keyEquivalent: "")
        }
    }
    
    func tableMenu(withDelegate delegate:NSMenuDelegate, andItems items:[NSMenuItem])-> NSMenu {
        let menu = NSMenu()
        for item in items {
            menu.addItem(item)
        }
        menu.delegate = delegate
        return menu
    }
    
    //MARK: ------MENU ACTIONS
    @IBAction func showInFinderClicked(_ sender: NSMenuItem) {
        var filePaths = [String]()
        
        
        if let table = sender.menu!.delegate as? NSTableView, table == self.installedFontsTable {
            filePaths.append(self.installer.fontFolderPath + "/" + self.installer.installedFonts[table.clickedRow])
        } else if let outline = sender.menu!.delegate as? NSOutlineView {
            let item = outline.item(atRow: outline.clickedRow)
            print(outline.clickedRow)
            if let font = item as? Font {
                filePaths.append(font.path!)
            } else if let f = item as? FontFamily {
                filePaths = (Array(f.fonts!) as! [Font]).map{return $0.path!}
            } else if let f = item as? FontFolder {
                filePaths.append(f.path!)
            }
        }

        self.showInFinder(paths:filePaths)
    }
    
    @IBAction func removeItem(_ sender: NSMenuItem) {
        if let table = sender.menu!.delegate as? NSTableView {
            let row = table.clickedRow
            let cell = table.view(atColumn: 0, row: row, makeIfNecessary: false) as! CustomCell
            
            if table == self.singleTagTable {
                self.dataManager.removeTag(tag: cell.fontTag!, fonts: self.fontsSelected())
                self.tagTable.reloadData()
                self.singleTagTable.reloadData()
            } else if table == self.tagTable {
                if self.confirmed("Delete Tag?", detail: "Are you sure you want to delete this tag? No backsies!") {
                    self.dataManager.removeTag(tag: cell.fontTag!, fonts: Array(cell.fontTag!.fonts!) as! [Font])
                    self.reloadAll()
                }
            }
        }
    }
    
    
    func showInFinder(paths:[String]) {
        
        var validURLs = [URL]()
        var errors = [String]()
        
        for path in paths {
            let url = URL(fileURLWithPath: path)
            if url.isFileURL && FileManager.default.fileExists(atPath: path){
                if url.hasDirectoryPath {
                    NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: path)
                    return
                }
                validURLs.append(url)
            } else {
                errors.append("\(path)\n")
            }
        }
        
        //check valid
        if validURLs.count > 0 {
            NSWorkspace.shared.activateFileViewerSelecting(validURLs)
        }
        //show errors
        if errors.count > 0 {
            self.errorFromArray(title: "Could not find the following files:", errors: errors)
        }
    }
    
    
    
    
}

extension ViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if outlineView == self.outlineView {
            if let family = item as? FontFamily {
                return self.fontsDisplayed[family]!.count
            }
            return self.familyKeys.count
        } else {
            
            if let md = item as? FontFolder {
                return md.subFolders!.count
            }
            return self.dataManager.allMainDirectories().count
        }
        
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if outlineView == self.outlineView {
            if let family = item as? FontFamily {
                let fonts = self.fontsDisplayed[family]!.sorted(by: { $0.name!.lowercased() < $1.name!.lowercased() })
                return fonts[index]
            }
            return self.familyKeys[index]
        } else {
            if let directory = item as? FontFolder {
                let subFolders = (Array(directory.subFolders!) as! [FontFolder]).sorted(by: { $0.name!.lowercased() < $1.name!.lowercased() })
               
                return subFolders[index]
            }
            return self.dataManager.allMainDirectories()[index]
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if outlineView == self.outlineView {
            if let family = item as? FontFamily {
                return self.fontsDisplayed[family]!.count > 1
            }
        } else {
            if let directory = item as? FontFolder {
                return directory.subFolders!.count > 0
            }
        }
        return false
    }
    
    
    //MARK: - ==============HANDLE SEGUES =================
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
       if let destinationVC = segue.destinationController as? TextExampleVC {
            destinationVC.delegate = self
        }
    }
}



extension ViewController: NSOutlineViewDelegate {
    
    
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var view:NSTableCellView?
        
        
        if outlineView == self.outlineView {
            view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "FontCell"), owner: self) as? NSTableCellView
            
            var installed = false
            var missing = false
            
            if let textField = view?.textField {
                if let family = item as? FontFamily {
                    let fonts = self.fontsDisplayed[family]!
                    if fonts.count < 2 && fonts.count > 0 {
                        let font = fonts[0]
                        textField.stringValue = font.name!
                    } else {
                        textField.stringValue = family.name!
                    }
                    installed = self.installer.fontsInstalled(fonts: fonts)
                    missing = self.fontsMissing(fonts: fonts)
                } else if let font = item as? Font{
                    textField.stringValue = "---" + font.name!.lastSection()
                    installed = self.installer.fontsInstalled(fonts: [font])
                    missing = self.fontsMissing(fonts: [font])
                }
                
                //Text Color
                if installed {
                    textField.textColor = NSColor.systemGreen
                } else if missing {
                    textField.textColor = NSColor.red
                } else {
                    textField.textColor = NSColor.black
                }
                self.singleTagTable.reloadData()
            }
            
            
        } else {
            
            view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "FolderCell"), owner: self) as? NSTableCellView
            if let textField = view?.textField {
            
                if let directory = item as? FontFolder {
                    view!.imageView!.image = directory.path!.finderIcon()
                    textField.stringValue = directory.name!
                }
            }
        }
        
        return view
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        let outline = notification.object as! NSOutlineView
        self.singleTagTable.reloadData()
        if outline == self.outlineView {
            self.toggleInstallRemove()
            self.toggleProjectButtons()
            self.tagAdder.isEnabled = self.outlineView.numberOfSelectedRows > 0
            self.addTagButton.isEnabled = self.outlineView.numberOfSelectedRows > 0
            if outline == self.outlineView && self.outlineView.numberOfSelectedRows == 1 {
                let selectedRow = self.outlineView.selectedRow
                var font:Font!
                if let item = outlineView.item(atRow: selectedRow) as? FontFamily {
                    if let regFont = item.regular() {
                        font = regFont
                    } else {
                        font = self.fontsDisplayed[item]![0]
                    }
                } else if let item = outlineView.item(atRow: selectedRow) as? Font {
                    font = item
                }
                if let typeface = font.path!.nsFont(self){
                    self.displayedFont = typeface
                    self.fontUpDisplay()
                }
            }
            print("going to toggle")
            self.toggleInstallRemove()
        } else if outline == self.folderTree {
            self.toggleRemove()
            self.populateFontWindow()
        }
    }
    
    func reloadFontView() {
        self.outlineView.reloadData()
        self.singleTagTable.reloadData()
        self.toggleInstallRemove()
        self.tagAdder.isEnabled = self.outlineView.numberOfSelectedRows > 0
        self.addTagButton.isEnabled = self.outlineView.numberOfSelectedRows > 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, mouseDownInHeaderOf tableColumn: NSTableColumn) {
        outlineView.deselectAll(self)
    }
    
    
    
    func fontsMissing(fonts:[Font], _ any:Bool = false)-> Bool {
        
        for font in fonts {
            if FileManager.default.fileExists(atPath: font.path!) == !any {
                return any
            } else {
                print("missing font at \(font.path!)")
            }
        }
        return !any
    }
    
}

extension ViewController: NSTextViewDelegate {
    
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            if textView == self.fontDisplay {
                self.fontUpDisplay()
                UserDefaults.standard.set(self.fontDisplay.string, forKey: "fontDisplay")
            }
        }
    
    func fontUpDisplay() {
        self.fontDisplay.textStorage?.setAttributedString(self.displayedFont.supportString(self.fontDisplay.string))
        self.fontDisplay.font = self.displayedFont
    }
}




