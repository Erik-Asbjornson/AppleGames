//
//  ViewControllerFunctions.swift
//  2D-Minecraft-Based-Game
//
//  Created by Erik Asbjornson on 11/15/19.
//  Copyright © 2019 Erik Asbjornson. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

extension NSViewController {
    
    //create button
    func Button(button: NSButton, position: NSPoint, size: NSSize, color: NSColor, text: String, action: Selector?) {
        button.setFrameOrigin(NSPoint(x: position.x, y: position.y))
        button.setFrameSize(size)
        button.image = NSImage.swatchWithColor(color: color, size: button.frame.size)
        button.title = text
        button.font = NSFont(name: "minecraft", size: 20)
        button.action = action
        view.addSubview(button)
    }
}

class OnlyIntegerFormatter: NumberFormatter {
    
    //copied and edited from answer to stackexchange(?) quoestion
    override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        
        // Ability to reset your field (otherwise you can't delete the content)
        // You can check if the field is empty later
        if partialString.isEmpty {return true}
        
        //Limit input length
         if partialString.count>10 {return false}
        
        // check if Int
        return Int(partialString) != nil
    }
}
