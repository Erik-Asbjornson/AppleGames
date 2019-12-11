//
//  WorldStart.swift
//  2D-Minecraft-Based-Game
//
//  Created by Erik Asbjornson on 11/14/19.
//  Copyright © 2019 Erik Asbjornson. All rights reserved.
//

import SpriteKit
import GameplayKit

extension GameScene {
    
    func createWorld () {
        title.removeFromParent()
        finePrint.removeFromParent()
        
        createGrid(x: -40*blockscol,y: 0)
        
        //create sprite nodes for hearts, hunger, hotbar, and sets up inventory
        startHearts()
        startHunger()
        startHotbar()
        startInventory()
        
        //add player
        func getName() -> String{
            for name in blocksName[blocksName.count/2] {
                if !name.isEmpty {return name}
            }
            return ""
        }
        let blockY = (scene?.childNode(withName: getName())?.position.y) ?? 0
        startPos = CGPoint(x: startPos.x, y: startPos.y+blockY)
        player.position = startPos
        player.zPosition = 4
        player.size = CGSize(width: player.size.width*144/player.size.height, height: 144)
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: player.size.width/2-1, height: player.size.height), center: CGPoint(x: player.position.x, y: player.position.y-startPos.y))
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.restitution = 0
        addChild(player)
        
        //add camera node
        player.addChild(cameraNode)
        scene?.camera = cameraNode
    }
    
    //creates hotbar
    func startHotbar() {
        let a: CGFloat = 0.8
        let boxSize = 64
        let hotBarPosX = heartsPosX-(iconWidth/2)-(boxSize/2)
        let hotBarPosY = iconPosY-(iconWidth/2)-(boxSize/2)-12
        
        //create border of hotbar
        let border = SKSpriteNode(color: NSColor(calibratedWhite: 0.8, alpha: a), size: CGSize(width: 10*boxSize+16, height: boxSize+16))
        border.position = CGPoint(x: hotBarPosX+boxSize*5+36, y: hotBarPosY)
        border.zPosition = 4
        player.addChild(border)
        
        //create boxes for hotbar
        for i in 1...9 {
            let item = SKSpriteNode(color: NSColor(calibratedWhite: 0.2, alpha: a), size: CGSize(width: boxSize, height: boxSize))
            item.name = "box,\(i)"
            item.position = CGPoint(x: hotBarPosX-4 + (i * (boxSize+8)), y: hotBarPosY)
            item.zPosition = 4
            player.addChild(item)
            hotbar.append("")
            let num = SKLabelNode(text: "0")
            num.name = "label,\(i-1)"
            num.position = CGPoint(x: hotBarPosX-4+boxSize/2 + (i * (boxSize+8)), y: hotBarPosY-boxSize/2)
            num.alpha = 0
            num.zPosition = 6
            num.fontName = "minecraft"
            num.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
            labels.append(0)
            player.addChild(num)
        }
        
        //create the selected box border
        selected = SKShapeNode(rect: CGRect(x: player.childNode(withName: "box,1")!.position.x-CGFloat(36), y: CGFloat(hotBarPosY-(boxSize/2)-4), width: CGFloat(boxSize+8), height: CGFloat(boxSize+8)))
        selected.name = "selected,1"
        selected.fillColor = .clear
        selected.strokeColor = NSColor(calibratedWhite: 1, alpha: 1)
        selected.lineWidth = 8
        selected.zPosition = 4
        player.addChild(selected)
    }
    
    //creates inventory so it opens faster
    func startInventory() {
        let boxSize = 64
        let hotBarPosX = heartsPosX-(iconWidth/2)-(boxSize/2)
        let hotBarPosY = iconPosY-(iconWidth/2)-(boxSize/2)-12
        
        //create border for inventory
        let border = SKSpriteNode(color: NSColor(calibratedWhite: 0.8, alpha: 1), size: CGSize(width: 10*boxSize+16, height: boxSize+16+216))
        border.name = "inventory"
        border.position = CGPoint(x: hotBarPosX+boxSize*5+36, y: hotBarPosY+108)
        border.zPosition = 4
        inventoryScreen.append(border)
        
        //create boxes for inventory
        for i in 0...3 {
            for j in 1...9 {
                let item = SKSpriteNode(color: NSColor(calibratedWhite: 0.2, alpha: 1), size: CGSize(width: boxSize, height: boxSize))
                item.name = "inv,\(j+i*9)"
                item.position = CGPoint(x: (10-j)*(boxSize+8)+hotBarPosX-4, y: hotBarPosY+i*72)
                item.zPosition = 4
                inventoryScreen.append(item)
                if i < 3 {
                    inventory.append("")
                    labels.append(0)
                }
            }
        }
    }
    
    //creates heart sprites
    func startHearts() {
        var item = SKSpriteNode()
        let name = "full_heart"
        for num in 0...9 {
            item = SKSpriteNode(imageNamed: name)
            item.name = name
            item.scale(to: CGSize(width: iconWidth, height: iconHeight))
            item.position = CGPoint(x: (num * iconWidth) + heartsPosX, y: iconPosY)
            item.zPosition = 4
            player.addChild(item)
            hearts.append(item)
        }
    }
    
    //creates hunger sprites
    func startHunger() {
        var item = SKSpriteNode()
        for num in 0...9 {
            item = SKSpriteNode(imageNamed: "full_hunger")
            item.scale(to: CGSize(width: iconWidth, height: iconHeight))
            item.position = CGPoint(x: (num * iconWidth) + hungerPosX, y: iconPosY)
            item.zPosition = 4
            player.addChild(item)
            hunger.append(item)
        }
    }
}
