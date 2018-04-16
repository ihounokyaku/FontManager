//
//  Extensions.swift
//  FontManager
//
//  Created by Dylan Southard on 2018/02/16.
//  Copyright © 2018年 Dylan Southard. All rights reserved.
//

import Foundation
import Cocoa
extension String {
    func fullrange() -> NSRange {
        let nsString = self as NSString
        return NSMakeRange(0, nsString.length)
    }
    
    func lastSection()-> String {
        if let index = (self.range(of: "-", options:NSString.CompareOptions.backwards)?.upperBound) {
            return String(self.suffix(from: index))
        }
        return self
    }
    func firstSection()-> String {
        if let index = (self.range(of: "-", options:NSString.CompareOptions.backwards)?.lowerBound) {
            return String(self.prefix(upTo: index))
        }
        return self
    }
    
    func withoutFileExtension()-> String {
        if let index = (self.range(of: ".", options:NSString.CompareOptions.backwards)?.lowerBound) {
            return String(self.prefix(upTo: index))
        }
        return self
    }
    
    
    func colorFromRGB(alpha: Float = 1.0) -> NSColor {
        let scanner = Scanner(string:self)
        var color:Int32 = 0;
        scanner.scanInt32(&color)
       // scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = CGFloat(Float(Int(color >> 16) & mask)/255.0)
        let g = CGFloat(Float(Int(color >> 8) & mask)/255.0)
        let b = CGFloat(Float(Int(color) & mask)/255.0)
        
        return NSColor(red: r, green: g, blue: b, alpha: CGFloat(alpha))
    }
    
    func finderIcon()-> NSImage {
        var image = #imageLiteral(resourceName: "batsu")
        if FileManager.default.fileExists(atPath: self) {
            image = NSWorkspace.shared.icon(forFile: self)
        }
        return image
    }
    
    func nsFont(_ sender:ViewController?)-> NSFont? {
        var nsFont : NSFont?
        
        if FileManager.default.isReadableFile(atPath: self) {
            
            let fontData = FileManager.default.contents(atPath: self)! as NSData
            
            if let dataProvider = CGDataProvider(data: fontData) {
                
                if let cgFont = CGFont(dataProvider) {
                    
                    var error: Unmanaged<CFError>?
                    if !CTFontManagerRegisterGraphicsFont(cgFont, &error)
                    {
                        if let vc = sender {
                            vc.errorAlert("Error Loading Font", detail: String(describing: error))
                        }
                    } else {
                        
                        var name = ""
                        if let n = cgFont.fullName as String? {
                            
                            name = n
                        } else {
                            name = URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
                        }
                       
                        let compName = name.replacingOccurrences(of: "#", with: "")
                        if let font = NSFont(name: compName , size: 30) {
                            nsFont = font
                        } else {
                            
                        }
                        
                    }
                } else {
                    print("could not load font \ndataprovider for \(self) is weird")
                }
            } else {
                print("could not load font \nfontData for \(self) is weird")
            }
        }
        return nsFont
    }
}

extension UnicodeScalar {
    func isIn(font:NSFont)-> Bool {
        let coreFont:CTFont = font
        let charSet:CharacterSet = CTFontCopyCharacterSet(coreFont) as CharacterSet
        if charSet.contains(self) {
            return true
        }
        return false
    }
}

extension FontFamily {
    func regular()-> Font? {
        let fonts = Array(self.fonts!) as! [Font]
        for font in fonts {
            if font.name!.lastSection() == "Regular" {
                return font
            }
        }
      return nil
    }
}

extension NSFont {
    
    func canDisplayString(str:String)-> Bool {
        for scalar in str.unicodeScalars {
            if !scalar.isIn(font: self) {
                return false
            }
        }
        return true
    }
    
    func supportString(_ str:String)-> NSAttributedString {
        let attString = NSMutableAttributedString(string: "")
        for scalar in str.unicodeScalars {
            if !scalar.isIn(font: self) {
                let r:CGFloat = 200
                let g:CGFloat = 0
                let b:CGFloat = 0
                let a:CGFloat = 0.8
                let color = NSColor(red: r, green: g, blue: b, alpha: a)
                let attcha = NSMutableAttributedString(string: String(scalar), attributes: [NSAttributedStringKey.foregroundColor:color, NSAttributedStringKey.strikethroughStyle:NSUnderlineStyle.styleSingle.rawValue])
                attString.append(attcha)
            } else {
                let attcha = NSAttributedString(string: String(scalar), attributes: [NSAttributedStringKey.foregroundColor:NSColor.black])
                attString.append(attcha)
            }
        }
        return attString
    }
}

extension Font {
    func canDisplayString(str:String)-> Bool {
        if let path = self.path {
            if let font = path.nsFont(nil) {
                if font.canDisplayString(str: str) {
                    return true
                }
            }
        }
        return false
    }
}

extension NSTableView : NSMenuDelegate {
    
}

enum MenuItemType {
    case remove
    case showInFinder
}

