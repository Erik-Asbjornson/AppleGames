//
//  Inventory.swift
//  2D-Minecraft-Based-Game
//
//  Created by Erik Asbjornson on 11/17/19.
//  Copyright © 2019 Erik Asbjornson. All rights reserved.
//
import SpriteKit
import GameplayKit

extension GameScene {
    func openInventory() {
        inventoryOpen = true
        
        //add inventory to screen, and remove hearts and hunger
        for item in inventoryScreen {player.addChild(item)}
        for heart in hearts {heart.removeFromParent()}
        for meat in hunger {meat.removeFromParent()}
        
        for i in 0..<inventory.count {
            
            //add item picture
            if inventory[i] == "" {continue}
            let token = inventory[i].components(separatedBy: ",")
            let item = SKSpriteNode(imageNamed: token[0])
            let posit = player.childNode(withName: "inv,\(27-i)")!.position
            let pos = CGPoint(x: posit.x, y: posit.y+72)
            item.name = token[0]+",bar,\(10+i)"
            item.position = pos
            item.zPosition = 5
            item.scale(to: CGSize(width: blockSize/2, height: blockSize/2))
            player.addChild(item)
            
            //add label
            let boxSize = 64
            if labels[9+i] == 0 {continue}
            let num = SKLabelNode(text: "0")
            num.name = "label,\(9+i)"
            num.position = CGPoint(x: pos.x+CGFloat(boxSize/2), y: pos.y-CGFloat(boxSize/2))
            num.zPosition = 6
            num.fontName = "minecraft"
            num.text = String(labels[9+i])
            num.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
            player.addChild(num)
        }
    }
    
    func closeInventory() {
        inventoryOpen = false
        
        //remove inventory to screen, and add hearts and hunger
        for item in inventoryScreen {item.removeFromParent()}
        for heart in hearts {player.addChild(heart)}
        for meat in hunger {player.addChild(meat)}
        
        //remove item pictures and labels
        for i in 0..<inventory.count {
            let token = inventory[i].components(separatedBy: ",")
            player.childNode(withName: token[0]+",bar,\(10+i)")?.removeFromParent()
            player.childNode(withName: "label,\(9+i)")?.removeFromParent()
        }
    }
}
