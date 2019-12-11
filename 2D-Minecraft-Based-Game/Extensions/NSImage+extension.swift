//
//  NSImage+extension.swift
//  2D-Minecraft-Based-Game
//
//  Created by Erik Asbjornson on 11/15/19.
//  Copyright © 2019 Erik Asbjornson. All rights reserved.
//

import SpriteKit
import GameplayKit

extension NSImage {
    
    //copied from answer to stackexchange(?) quoestion
    class func swatchWithColor(color: NSColor, size: NSSize) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()
        color.drawSwatch(in: NSMakeRect(0, 0, size.width, size.height))
        image.unlockFocus()
        return image
    }
}
