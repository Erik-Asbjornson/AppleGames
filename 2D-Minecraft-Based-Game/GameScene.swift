//
//  GameScene.swift
//  2D-Minecraft-Based-Game
//
//  Created by Erik Asbjornson on 9/5/19.
//  Copyright © 2019 Erik Asbjornson. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
     
    //initialize title and finePrint
    var title = SKSpriteNode(imageNamed: "2D-Minecraft-Based-Game")
    var finePrint = SKLabelNode(text: "NOT AN OFFICIAL MINECRAFT PRODUCT. NOT APPROVED BY OR ASSOCIATED WITH MOJANG.")
    
    //check if inGame
    var inGame = false {
        didSet {
            if inGame {
                createWorld()
                scene!.backgroundColor = NSColor(calibratedRed: 0.494, green: 0.753, blue:0.933, alpha: 1)
            }
            else {scene!.backgroundColor = NSColor(calibratedWhite: 0, alpha: 1)}
        }
    }
    
    //initialize seed for noise map and player sprite
    var seed = Int32.random(in: -2147483648...2147483647)
    var player = SKSpriteNode(imageNamed: "steveRight")
    
    //variables for breaking blocks
    let Break = SKSpriteNode(imageNamed: "Break1")
    var selected = SKShapeNode()
    var broken = 1
    var mouseTimer: Timer?
    
    //timers for health and hunger
    var hungerTimer: Timer?
    var regenTimer: Timer?
    var regen2Timer: Timer?
    var damageTimer: Timer?
    
    //variables for placing blocks
    var tappedNodes = [SKNode]()
    var reach = CGPoint(x: 200, y: 240-1)
    
    //variables for generating terrain
    var blocksName = [[String]]()
    var biome = [String]()
    var startPos = CGPoint(x: 0, y: 120)
    let blockSize = 80
    let blocksrow = 32
    let blockscol = 256
    let biomeSize = 64
    
    //initialize camera node
    let cameraNode = SKCameraNode()
    
    //variables for movement
    var fallStart: CGFloat? = nil
    let moveSpeed = 5.0
    var L = false
    var R = false
    var U = false
    var D = false
    
    //variables for sprinting
    var runTimerL: Timer?
    var runTimerR: Timer?
    var sprinting = false
    let sprintDelay = 0.5
    var sprintDistance = 0.0
    var deltaTimeL: TimeInterval = 0
    var deltaTimeR: TimeInterval = 0
    
    var hotbar = [String]() {
        didSet {
            //adds sprite into hotbar
            for i in 0..<hotbar.count {
                if hotbar[i] == "" {continue}
                let token = hotbar[i].components(separatedBy: ",").first!
                if player.childNode(withName: token+",bar,\(i+1)") != nil {continue}
                let item = SKSpriteNode(imageNamed: token)
                item.name = token+",bar,\(i+1)"
                item.position = player.childNode(withName: "box,\(i+1)")!.position
                item.zPosition = 5
                item.scale(to: CGSize(width: blockSize/2, height: blockSize/2))
                player.addChild(item)
            }
        }
    }
    
    var inventory = [String]() {
        didSet {
            //adds sprite into inventory when it is open
            if !inventoryOpen {return}
            for i in 0..<inventory.count {
                let token = inventory[i].components(separatedBy: ",").first!
                if inventory[i] == "" || player.childNode(withName: token+",bar,\(10+i)") != nil {continue}
                let posit = player.childNode(withName: "inv,\(27-i)")!.position
                let pos = CGPoint(x: posit.x, y: posit.y+72)
                let item = SKSpriteNode(imageNamed: token)
                item.name = token+",bar,\(10+i)"
                item.position = pos
                item.zPosition = 5
                item.scale(to: CGSize(width: blockSize/2, height: blockSize/2))
                player.addChild(item)
            }
        }
    }
    
    //variables for opening inventory
    var inventoryScreen = [SKNode]()
    var inventoryOpen = false
    
    //variables for moving items in hotbar and inventory
    var touchingBlock = false
    var touched = SKSpriteNode()
    
    var labels = [Int]() {
        didSet {
            //sets hotbar labels
            for i in 0..<9 {
                guard let label = player.childNode(withName: "label,\(i)") as? SKLabelNode else {break}
                if labels[i] == 0 {
                    label.alpha = 0
                    continue
                }
                if label.alpha == 0 {label.alpha = 1}
                label.text = "\(labels[i])"
            }
            //sets inventory labels when open
            if !inventoryOpen {return}
            for i in 9..<inventory.count+9 {
                if labels[i] == 0 {
                    if player.childNode(withName: "label,\(i)") != nil {
                        player.childNode(withName: "label,\(i)")!.removeFromParent()
                    }
                    continue
                }
                if player.childNode(withName: "label,\(i)") != nil {
                    (player.childNode(withName: "label,\(i)") as! SKLabelNode).text = "\(labels[i])"
                    continue
                }
                let posit = player.childNode(withName: "inv,\(36-i)")!.position
                let pos = CGPoint(x: posit.x, y: posit.y+72)
                let boxSize = 64
                let num = SKLabelNode(text: "0")
                num.name = "label,\(i)"
                num.position = CGPoint(x: pos.x+CGFloat(boxSize/2), y: pos.y-CGFloat(boxSize/2))
                num.zPosition = 6
                num.fontName = "minecraft"
                num.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
                player.addChild(num)
                num.text = "\(labels[i])"
            }
        }
    }
    
    //variables for health
    var hearts = [SKSpriteNode]()
    var fullLoss = [SKTexture]()
    var halfLoss = [SKTexture]()
    var halfLoss2 = [SKTexture]()
    var health = 20
    var noDamage = Date().timeIntervalSince1970
    var prevDamage = 0
    
    //variables for hunger
    var hunger = [SKSpriteNode]()
    var hungerLeft: Decimal = 20
    var exhaustion: Decimal = 0
    var saturation: Decimal = 5
    
    //variables for size of hearts and hunger sprites
    let iconWidth = 30
    let iconHeight = 30
    let heartsPosX = -310
    let hungerPosX = 40
    let iconPosY = -250
    
    //biome variable
    var biomeBlocks = BiomeBlocks()
    
    override func didMove(to view: SKView) {
        // Called when program is opened
        physicsWorld.contactDelegate = self
        
        //create heart texture atlas arrays
        let textureAtlas = SKTextureAtlas(named: "hearts")
        fullLoss.append(textureAtlas.textureNamed("full_heart"))
        fullLoss.append(textureAtlas.textureNamed("empty_heart"))
        halfLoss.append(textureAtlas.textureNamed("half_heart"))
        halfLoss.append(textureAtlas.textureNamed("empty_heart"))
        halfLoss2.append(textureAtlas.textureNamed("full_heart"))
        halfLoss2.append(textureAtlas.textureNamed("half_heart"))
        
        //create title
        title.size = CGSize(width: 900, height: title.size.height*900/title.size.width)
        title.position = CGPoint(x: 475, y: 600)
        addChild(title)
        
        //create fine print
        finePrint.position = CGPoint(x: 475, y: 0)
        finePrint.fontName = "minecraft"
        finePrint.fontSize = 8
        addChild(finePrint)
    }
    
    /*func lightSource(lightLevel: Int) {unimplemented}*/
    /*func potionEffect(name: String,level: Int) {unimplemented}*/
    /*func regeneration() {//regeneration potion heart wave
        for heart in 0..<hearts.count {
            let wait = SKAction.wait(forDuration: TimeInterval(heart)/30)
            let up = SKAction.move(by: CGVector(dx: 0, dy: 10), duration: 0.1)
            let down = SKAction.move(by: CGVector(dx: 0, dy: -10), duration: 0.1)
            let sequence = SKAction.sequence([wait,up,down])
            hearts[heart].run(sequence)
        }
    }*/
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if inGame {
            //if player is falling
            if player.physicsBody!.velocity.dy < -0.1 {
                if fallStart == nil {fallStart = player.position.y}
            }
            
            //fall distance
            if fallStart != nil && abs(player.physicsBody!.velocity.dy) < 0.1 {
                let dist = floor((fallStart! - player.position.y)/CGFloat(blockSize))-3
                if dist > 0 {health(lost: Int(dist))}
                fallStart = nil
            }
            
            //not best way to do it, but checks hunger
            checkHunger()
            
            //if can jump
            if U {if abs(player.physicsBody!.velocity.dy) < 0.1 {jump()}}
            
            //if below lowest block die
            if Int(player.position.y) < -80*blocksrow-80 {die()}
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // Called when physics bodys report contact
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        if nodeA == player {playerHit(nodeB)}
        if nodeB == player {playerHit(nodeA)}
    }
    
    func playerHit(_ node: SKNode) {
        // Called when player makes contact with item drop
        let token = node.name!.components(separatedBy: ",").first!
        let isBlock = node.userData!.value(forKey: "isBlock") as! String
        let selected = self.selected.name!.components(separatedBy: ",").last!
        
        //checks hotbar for matching item that is not in a full stack
        for i in 0..<hotbar.count {
            let hotToken = hotbar[i].components(separatedBy: ",").first
            if hotToken == token && labels[i] < 64 {
                labels[i]+=1
                node.removeFromParent()
                return
            }
        }
        
        //checks inventory for matching item that is not in a full stack
        for i in 0..<inventory.count {
            let invToken = inventory[i].components(separatedBy: ",").first
            if invToken == token && labels[9+i] < 64 {
                labels[9+i]+=1
                node.removeFromParent()
                return
            }
        }
        
        //check if the selected hotbar box is empty or contains matching item
        let select = hotbar[Int(selected)!-1].components(separatedBy: ",").first
        if select == token && labels[Int(selected)!-1] < 64 {
            labels[Int(selected)!-1]+=1
            node.removeFromParent()
            return
        }
        if select == "" {
            hotbar[Int(selected)!-1] = token+","+isBlock
            labels[Int(selected)!-1]=1
            node.removeFromParent()
            return
        }
        
        //checks for empty box in hotbar
        for i in 0..<hotbar.count {
            if hotbar[i] == "" {
                hotbar[i] = token+","+isBlock
                labels[i]=1
                node.removeFromParent()
                return
            }
        }
        
        //checks for empty box in inventory
        for i in 0..<inventory.count {
            if inventory[i] == "" {
                inventory[i] = token+","+isBlock
                labels[9+i]=1
                node.removeFromParent()
                return
            }
        }
    }
}
