//
//  Mouse.swift
//  2D-Minecraft-Based-Game
//
//  Created by Erik Asbjornson on 11/14/19.
//  Copyright © 2019 Erik Asbjornson. All rights reserved.
//

import SpriteKit
import GameplayKit

extension GameScene {
    
    func touchDown(atPoint pos : CGPoint) {
        
        tappedNodes = nodes(at: pos)
        
        //checks if the mouse position is within 3 blocks on the x-axis and 2 blocks on the y-axis
        if abs(convert(pos, to: cameraNode).x - convert(player.position, to: cameraNode).x) < reach.x &&
                abs(convert(pos, to: cameraNode).y - convert(player.position, to: cameraNode).y) < reach.y {
            
            let filter = tappedNodes.filter(){$0 != player && !hearts.contains($0 as! SKSpriteNode) && !hunger.contains($0 as! SKSpriteNode)}
            
            if filter.count > 0 {
                
                let token = filter.first?.name?.components(separatedBy: ",")
                if token?.last == "drop" {return}
                
                //adds Break sprite to view
                Break.position = filter.first!.position
                Break.zPosition = 4
                addChild(Break)}
            
            //timer to increment Break sprite texture and remove the block
            mouseTimer = Timer.scheduledTimer(withTimeInterval: 1/6, repeats: true) {(mouseTimer) in self.mouseWasHeld(pos)}
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
        //if no blocks call touchUp
        let none = nodes(at: pos).filter(){$0 != player}
        if none == [] {
            touchUp(atPoint: pos)
            return
        }
        
        let check = nodes(at: pos).filter(){$0 != Break}
        if tappedNodes != check {
            
            //if new nodes remove Break sprite and timer
            tappedNodes = nodes(at: pos)
            mouseTimer?.invalidate()
            mouseTimer = nil
            broken = 1
            Break.removeFromParent()
            
            //checks if the mouse position is within 3 blocks on the x-axis and 2 blocks on the y-axis
            if abs(convert(pos, to: cameraNode).x - convert(player.position, to: cameraNode).x) < reach.x &&
                abs(convert(pos, to: cameraNode).y - convert(player.position, to: cameraNode).y) < reach.y {
                
                let filter = tappedNodes.filter(){$0 != player && !hearts.contains($0 as! SKSpriteNode) && !hunger.contains($0 as! SKSpriteNode)}
                
                if filter.count > 0 {
                    
                    //checks if what was clicked is an item drop
                    let token = filter.first?.name?.components(separatedBy: ",")
                    if token?.last == "drop" {
                        return
                    }
                    
                    //adds Break sprite to view
                    Break.texture = SKTexture(imageNamed: "Break\(broken)")
                    Break.position = filter.first!.position
                    Break.zPosition = 4
                    addChild(Break)
                }
                
                //timer to increment Break sprite texture and remove the block
                mouseTimer = Timer.scheduledTimer(withTimeInterval: 1/6, repeats:true){(mouseTimer) in self.mouseWasHeld(pos)}
            }
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        //ends timer and removes/resets Break sprite
        tappedNodes.removeAll()
        mouseTimer?.invalidate()
        mouseTimer = nil
        Break.removeFromParent()
        Break.texture = SKTexture(imageNamed: "Break1")
        broken = 0
    }
    
    func mouseWasHeld(_ pos: CGPoint) {
        // Called when Break texture is incremented, removes the clicked blocks, and calls drop function
        
        //increments Break texture and removes it when done
        broken+=1
        if broken < 7 {
            Break.texture = SKTexture(imageNamed: "Break\(broken)")
            return
        }
        broken=0
        Break.removeFromParent()
        
        var blocks = nodes(at: pos).filter(){$0 != player && !hearts.contains($0 as! SKSpriteNode) && !hunger.contains($0 as! SKSpriteNode)}
        
        //removes clicked blocks and drops the corresponding item(s)
        if blocks.count > 0 {
            for block in 1...blocks.count {
                let rem = blocks[block-1]
                rem.removeFromParent()
                if let name = rem.name {drop(name)}
            }
            
            exhaustion(increase: 0.005)
        }
        tappedNodes = nodes(at: pos)
    }
    
    override func rightMouseDown(with event: NSEvent) {
        
        let pos = event.location(in: self)
        
        //check to make sure there is something in the seleced hotbar box
        let token = selected.name!.components(separatedBy: ",")
        let i = Int(token[1])!-1
        let hotToken = hotbar[i].components(separatedBy: ",")
        if hotbar[i] == "" {
            return
        }
        
        //check if click is within range
        if abs(convert(pos, to: cameraNode).x - convert(player.position, to: cameraNode).x) < reach.x &&
            abs(convert(pos, to: cameraNode).y - convert(player.position, to: cameraNode).y) < reach.y {
            
            //check to make sure there are no other blocks
            let Nodes = nodes(at: pos).filter(){$0 != player}
            if Nodes.count == 0 {
                
                //check to make sure the block will not be on top of the player
                let xpos = ceil((pos.x-40)/80)+CGFloat(blockscol/2)-ceil((player.position.x-40)/80)-CGFloat(blockscol/2)
                let ypos = ceil((pos.y-40)/80)+CGFloat(blockscol/2)-ceil((player.position.y-40)/80)-CGFloat(blockscol/2)
                if xpos != 0 || ypos != 0 && ypos != 1 {
                    
                    //check if selected item is food
                    if hotToken[1] == "food" && hungerLeft < 20 {
                        hunger(eaten: 4, sat: 2.4)
                        decLabel(hotToken, i)
                        return
                    }
                    
                    //check if selected item is a block
                    if hotToken[1] != "true" && hotToken[1] != "trans" {
                        return
                    }
                    
                    //check if block will have a physics body
                    var physics = true
                    if hotToken[1] == "trans" {
                        physics = false
                    }
                    
                    //add block and decrease item count in hotbar
                    let position = CGPoint(x: ceil((pos.x-40)/80)+CGFloat(blockscol/2), y: -ceil((pos.y-40)/80))
                    addBlock(image: hotToken[0], -40*blockscol, 0, Int(position.y), Int(position.x), 1, physics)
                    decLabel(hotToken, i)
                    
                    //check if grass block is directly below placed block and if yes replace with Dirt
                    let nod = nodes(at: CGPoint(x: pos.x, y: pos.y-80)).filter(){$0 != player}
                    if nod.first?.name?.components(separatedBy: ",").first == "Grass" {
                        nod.first!.removeFromParent()
                        addBlock(image: "Dirt", -40*blockscol, 0, Int(position.y)+1, Int(position.x))
                    }
                }
            }
        }
    }
    
    func decLabel(_ hotToken: [String],_ i: Int) {
        // Called when an item is dropped/used from the hotbar
        if labels[i] == 0 {return}
        labels[i]-=1
        if labels[i] == 0{
            player.childNode(withName: hotToken[0]+",bar,\(i+1)")!.removeFromParent()
            hotbar[i] = ""
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        if !inventoryOpen {
            self.touchDown(atPoint: event.location(in: self))
        } else {
            self.inventoryDown(atPoint: event.location(in: self))
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        if !inventoryOpen {
        self.touchMoved(toPoint: event.location(in: self))
        } else {
            self.inventoryMoved(toPoint: event.location(in: self))
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        if !inventoryOpen {
        self.touchUp(atPoint: event.location(in: self))
        } else {
            self.inventoryUp(atPoint: event.location(in: self))
        }
    }
    
    func inventoryDown(atPoint pos : CGPoint) {
        // Called on right mouse down while inventory is open
        
        let tappedNodes = nodes(at: pos)
        var screen = inventoryScreen
        
        //check if tapped box is in hotbar and contains something
        for i in 1...9 {
            if hotbar[i-1] == "" {continue}
            let token = hotbar[i-1].components(separatedBy: ",").first!
            
            if tappedNodes.contains(screen[10-i]) {
                touchingBlock = true
                touched = player.childNode(withName: token+",bar,\(i)") as! SKSpriteNode
                return
            }
        }
        
        //check if tapped box is in inventory and contains something
        for i in 0..<inventory.count {
            if inventory[i] == "" {continue}
            let token = inventory[i].components(separatedBy: ",").first!
            
            if tappedNodes.contains(screen[36-i]) {
                touchingBlock = true
                touched = player.childNode(withName: token+",bar,\(10+i)") as! SKSpriteNode
                return
            }
        }
    }
    
    func inventoryMoved(toPoint pos : CGPoint) {
        
        guard touchingBlock else {return}
        
        let token = Int(touched.name!.components(separatedBy: ",").last!)!-1
        let loc = convert(pos, to: cameraNode)
        
        //change position of item
        touched.position = loc
        touched.zPosition+=1
        
        //change position of item's label
        player.childNode(withName: "label,\(token)")?.position = CGPoint(x: loc.x+32, y: loc.y-32)
        player.childNode(withName: "label,\(token)")?.zPosition+=1
    }
    
    func inventoryUp(atPoint pos : CGPoint) {
        
        guard touchingBlock else {return}
        
        touchingBlock = false
        let token = Int(touched.name!.components(separatedBy: ",").last!)!-1
        player.childNode(withName: "label,\(token)")?.zPosition-=1
        let loc = convert(pos, to: cameraNode)
        let touchPos = CGPoint(x: 5-ceil((loc.x-36)/72), y: (ceil((loc.y-18)/72)+4)*9)
        
        //set boxPos based on if moved item is from hotbar or inventory
        var boxPos = CGPoint()
        if token < 9 {
            boxPos = player.childNode(withName: "box,\(token+1)")!.position
        }
        else {
            boxPos = player.childNode(withName: "inv,\(token)")!.position
        }
        
        //check if placed in hotbar or inventory
        if Int(touchPos.x+touchPos.y) <= 9 {
            
            let new = 9-Int(touchPos.x+touchPos.y)
            touched.removeFromParent()
            flipLabels(token, new)
            
            //check if from hotbar or inventory
            if token < 9 {
                
                //flip positions of items
                let temp = hotbar[token]
                hotbar[token] = hotbar[new]
                player.childNode(withName: (hotbar[new].components(separatedBy: ",").first ?? "")+",bar,\(new+1)")?.removeFromParent()
                hotbar[new] = temp
            } else {
                boxPos = player.childNode(withName: "inv,\(45-token)")!.position
                
                //flip positions of items
                let temp = inventory[token-9]
                inventory[token-9] = hotbar[new]
                player.childNode(withName: (hotbar[new].components(separatedBy: ",").first ?? "")+",bar,\(new+1)")?.removeFromParent()
                hotbar[new] = temp
            }
            
            (player.childNode(withName: "label,\(token)") as? SKLabelNode)?.position = CGPoint(x: boxPos.x+32, y: boxPos.y-32)
        } else {
            
            let new = 45-Int(touchPos.x+touchPos.y)
            touched.removeFromParent()
            flipLabels(token, new)
            
            if token < 9 {
                
                //flip positions of items
                let temp = hotbar[token]
                hotbar[token] = inventory[new-9]
                player.childNode(withName: (inventory[new-9].components(separatedBy: ",").first ?? "")+",bar,\(new+1)")?.removeFromParent()
                inventory[new-9] = temp
            } else {
                boxPos = player.childNode(withName: "inv,\(45-token)")!.position
                
                //flip positions of items
                let temp = inventory[token-9]
                inventory[token-9] = inventory[new-9]
                player.childNode(withName: (inventory[new-9].components(separatedBy: ",").first ?? "")+",bar,\(new+1)")?.removeFromParent()
                inventory[new-9] = temp
            }
            
            //set moved item's label position
            (player.childNode(withName: "label,\(token)") as? SKLabelNode)?.position = CGPoint(x: boxPos.x+32, y: boxPos.y-32)
        }
        
        //make sure hotbar and inventory show all items
        hotbar[0] = hotbar[0]
        inventory[0] = inventory[0]
        
        //reset touched
        touched = SKSpriteNode()
    }
    
    //flips the values of two labels
    func flipLabels(_ one: Int,_ two: Int) {
        let temp = labels[two]
        labels[two] = labels[one]
        labels[one] = temp
    }
}
