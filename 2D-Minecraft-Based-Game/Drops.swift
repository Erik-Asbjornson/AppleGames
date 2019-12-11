//
//  Drops.swift
//  2D-Minecraft-Based-Game
//
//  Created by Erik Asbjornson on 11/19/19.
//  Copyright © 2019 Erik Asbjornson. All rights reserved.
//

import SpriteKit
import GameplayKit

extension GameScene {
    
    func drop(_ name: String) {
        // Called when player destroys a block
        if name == Break.name {return}
        let token = name.components(separatedBy: ",")
        switch token[0] {
        case "Grass", "Dirt": drops("Dirt")
        case "Stone", "Cobblestone": drops("Cobblestone")
        case "Deadbush": drops("Stick", Int.random(in: 1...2), isBlock: "false")
        case "Leaves":
            if Int.random(in: 1...20) == 1 {
                if Bool.random() {drops("Stick", Int.random(in: 0...2), isBlock: "false")
                } else {drops("Sapling", isBlock: "trans")}
            }
            //will be 1...200 in future, but in the demo this is the only source of food
            if Int.random(in: 1...2) == 1 {drops("Apple", 1, isBlock: "food")}
        default: drops(token[0])
        }
    }
    
    //creates the item drop sprites
    func drops(_ name: String,_ num: Int = 1, isBlock: String = "true") {
        for _ in 1...num {
            let item = SKSpriteNode(imageNamed: name)
            item.name = name+",drop"
            item.position = Break.position
            item.zPosition = 3
            addChild(item)
            item.scale(to: CGSize(width: blockSize/2, height: blockSize/2))
            item.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: blockSize/2, height: blockSize/2), center: CGPoint.zero)
            item.physicsBody?.restitution = 0
            item.physicsBody?.velocity = CGVector(dx: Int.random(in: -blockSize/2...blockSize/2), dy: Int.random(in: 200...400))
            item.physicsBody?.contactTestBitMask = 1
            item.physicsBody?.categoryBitMask = 0
            item.physicsBody?.allowsRotation = false
            item.userData = NSMutableDictionary()
            item.userData?.setValue(isBlock, forKeyPath: "isBlock")
            let up = SKAction.move(by: CGVector(dx: 0, dy: 100), duration: 0.5)
            let down = SKAction.wait(forDuration: 0.5)
            let sequence = SKAction.sequence([up,down])
            let forever = SKAction.repeatForever(sequence)
            item.run(forever, withKey: "float")
            item.run(SKAction.sequence([SKAction.wait(forDuration: 300), SKAction.removeFromParent()]))
        }
    }
    
    func hotDrop(_ name: String, dead: Bool = false) {
        // Called when player drops an item from inventory
        let token = name.components(separatedBy: ",")
        switch token[0] {
        case "Stick": hotDrops("Stick", isBlock: "false", dead)
        case "Sapling": hotDrops("Sapling", isBlock: "trans", dead)
        case "Apple": hotDrops("Apple", isBlock: "food", dead)
        default: hotDrops(token[0], dead)
        }
    }
    
    //not best way, but creates item drop when player removes an item from inventory or dies
    func hotDrops(_ name: String, isBlock: String = "true",_ dead: Bool = false) {
        let item = SKSpriteNode(imageNamed: name)
        item.name = name+",drop"
        item.zPosition = 3
        item.scale(to: CGSize(width: blockSize/2, height: blockSize/2))
        addChild(item)
        item.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: blockSize/2, height: blockSize/2), center: CGPoint.zero)
        item.physicsBody?.restitution = 0
        if dead {
            item.position = player.position
            item.physicsBody?.velocity = CGVector(dx: Int.random(in: -blockSize/2...blockSize/2), dy: Int.random(in: 200...400))
        } else {
            var facing: CGFloat = 60
            var dir = 1
            if player.texture!.description == SKTexture(imageNamed: "steveLeft").description {
                facing = -facing
                dir = -1
            }
            item.position = CGPoint(x: player.position.x+facing, y: player.position.y+8)
            item.physicsBody?.velocity = CGVector(dx: Int.random(in: 200...300)*dir, dy: 0)
        }
        item.physicsBody?.contactTestBitMask = 1
        item.physicsBody?.categoryBitMask = 0
        item.userData = NSMutableDictionary()
        item.userData?.setValue(isBlock, forKeyPath: "isBlock")
        let up = SKAction.move(by: CGVector(dx: 0, dy: 100), duration: 0.5)
        let down = SKAction.wait(forDuration: 0.5)
        let sequence = SKAction.sequence([up,down])
        let forever = SKAction.repeatForever(sequence)
        item.run(forever, withKey: "float")
        item.run(SKAction.sequence([SKAction.wait(forDuration: 300), SKAction.removeFromParent()]))
    }
}
