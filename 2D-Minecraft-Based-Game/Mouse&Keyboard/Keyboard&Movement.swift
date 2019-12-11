//
//  Keyboard&Movement.swift
//  2D-Minecraft-Based-Game
//
//  Created by Erik Asbjornson on 11/14/19.
//  Copyright © 2019 Erik Asbjornson. All rights reserved.
//

import SpriteKit
import GameplayKit

extension GameScene {
    
    override func keyDown(with event: NSEvent) {
        
        //if not in game do nothing
        if !inGame {return}
        
        switch event.keyCode {
        //case 0x31: //spacebar
            //print("hello")
        case 0x7B: //left arrow
            
            //if left arrow not pressed
            if !L {
                L = true
                player.texture = SKTexture(imageNamed: "steveLeft")
                var dist = -moveSpeed
                
                //check time between left arrow up and down if true start sprinting
                if NSDate().timeIntervalSince1970-deltaTimeL <= sprintDelay {
                    sprintingEnd()
                    sprinting = true
                    dist = dist*1.33
                    hungerTimer = Timer.scheduledTimer(withTimeInterval: Double(blockSize)/(30*moveSpeed*1.33), repeats: true){(hungerTimer) in self.exhaustion(increase: 0.1)}
                }
                
                //movement timer
                endMoveL()
                runTimerL = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true){(runTimer) in self.move(dist)}
            }
        case 0x7C: //right arrow
            
            //if right arrow not pressed
            if !R {
                R = true
                player.texture = SKTexture(imageNamed: "steveRight")
                var dist = moveSpeed
                
                //check time between right arrow up and down if true start sprinting
                if NSDate().timeIntervalSince1970 - deltaTimeR <= sprintDelay {
                    sprintingEnd()
                    sprinting = true
                    dist = dist*1.33
                    hungerTimer = Timer.scheduledTimer(withTimeInterval: Double(blockSize)/(30*moveSpeed*1.33), repeats: true){(hungerTimer) in self.exhaustion(increase: 0.1)}
                }
                
                //movement timer
                endMoveR()
                runTimerR = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) {(runTimer) in self.move(dist)}
            }
        case 0x7E: //up arrow
            U = true
        case 0x7D: //down arrow does nothing
            D = true
        case 12: // q button
            
            //find selected hotbar item
            let token = Int(selected.name!.components(separatedBy: ",").last!)!-1
            if hotbar[token] == "" {return}
            let hotToken = hotbar[token].components(separatedBy: ",")
            
            //drop selected hotbar item and decrease label
            hotDrop(hotToken[0])
            decLabel(hotToken, token)
        case 14: // e button
            if !inventoryOpen {openInventory()}
            else {closeInventory()}
        case 18: // 1 button
            selected.name = "selected,1"
            selected.position.x = player.childNode(withName: "box,1")!.position.x+289
        case 19: // 2 button
            selected.name = "selected,2"
            selected.position.x = player.childNode(withName: "box,2")!.position.x+289
        case 20: // 3 button
            selected.name = "selected,3"
            selected.position.x = player.childNode(withName: "box,3")!.position.x+289
        case 21: // 4 button
            selected.name = "selected,4"
            selected.position.x = player.childNode(withName: "box,4")!.position.x+289
        case 23: // 5 button
            selected.name = "selected,5"
            selected.position.x = player.childNode(withName: "box,5")!.position.x+289
        case 22: // 6 button
            selected.name = "selected,6"
            selected.position.x = player.childNode(withName: "box,6")!.position.x+289
        case 26: // 7 button
            selected.name = "selected,7"
            selected.position.x = player.childNode(withName: "box,7")!.position.x+289
        case 28: // 8 button
            selected.name = "selected,8"
            selected.position.x = player.childNode(withName: "box,8")!.position.x+289
        case 25: // 9 button
            selected.name = "selected,9"
            selected.position.x = player.childNode(withName: "box,9")!.position.x+289
        default: // if unknown key print code and character
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    override func keyUp(with event: NSEvent) {
        switch event.keyCode {
        //case 0x31: // spacebar
            //print("Bye")
        case 0x7B: // left arrow
            L = false
        deltaTimeL = NSDate().timeIntervalSince1970
        endMoveL()
        if sprinting == true {sprintingEnd()}
        case 0x7C: // right arrow
            R = false
        deltaTimeR = NSDate().timeIntervalSince1970
        endMoveR()
        if sprinting == true {sprintingEnd()}
        case 0x7E: // up arrow
            U = false
        case 0x7D: // down arrow
            D = false
        default: // if unknown key print code and character
            print("keyUp: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    func move(_ dist: Double) {
        // Called when left or right arrow is pressed
        
        var blocked = false
        
        //move player
        let move = SKAction.move(by: CGVector(dx: nextToBlock(dist, &blocked), dy: 0), duration: 0.01)
        player.run(move)
        
        // if running into a block stop sprinting
        if blocked {sprintingEnd()} else {
            if sprinting {
                sprintDistance+=abs(dist)
                if Int(sprintDistance) >= blockSize {
                    exhaustion(increase: 0.1)
                    sprintDistance-=Double(blockSize)
                }
            }
        }
    }
    
    func endMoveL() {
        runTimerL?.invalidate()
        runTimerL = nil
    }
    
    func endMoveR() {
        runTimerR?.invalidate()
        runTimerR = nil
    }
    
    func jump() {
        // Called when up arrow is pressed
        
        player.physicsBody?.velocity = CGVector(dx: player.physicsBody!.velocity.dx, dy: 570)
        if sprinting {exhaustion(increase: 0.2)} else {exhaustion(increase: 0.05)}
    }
    
    //ends sprinting timer and sets sprint to false
    func sprintingEnd() {
        hungerTimer?.invalidate()
        hungerTimer = nil
        sprinting = false
    }
    
    //check if running into a block
    func nextToBlock(_ dist: Double,_ blocked: inout Bool) -> Double{
        let mask: UInt32 = 4294967295
        
        //check if moving right
        if dist > 0 {
            
            let x: CGFloat = player.position.x+player.size.width/4+CGFloat(dist)+3
            let nodesBottom = nodes(at: CGPoint(x: x, y: player.position.y-32)).filter(){$0 != player}
            let nodesTop = nodes(at: CGPoint(x: x, y: player.position.y+48)).filter(){$0 != player}
            
            //check if block has physics body
            if nodesBottom.first?.physicsBody?.categoryBitMask == mask || nodesTop.first?.physicsBody?.categoryBitMask == mask {
                blocked = true
                let pos = nodesBottom.first?.position.x ?? nodesTop.first!.position.x
                let size = CGFloat((nodesBottom.first as? SKSpriteNode)?.size.width ?? (nodesTop.first as? SKSpriteNode)!.size.width)/2
                switch abs(pos-size-x) {
                case let i where i>=10 && i<=15: return -0.1
                default: return 0
                }
            }
        } else {
            
            let x = player.position.x-player.size.width/4+CGFloat(dist)-3
            let nodesBottom = nodes(at: CGPoint(x: x, y: player.position.y-32)).filter(){$0 != player}
            let nodesTop = nodes(at: CGPoint(x: x, y: player.position.y+48)).filter(){$0 != player}
            
            //check if block has physics body
            if nodesBottom.first?.physicsBody?.categoryBitMask == mask || nodesTop.first?.physicsBody?.categoryBitMask == mask {
                blocked = true
                let pos = nodesBottom.first?.position.x ?? nodesTop.first!.position.x
                let size = CGFloat((nodesBottom.first as? SKSpriteNode)?.size.width ?? (nodesTop.first as? SKSpriteNode)!.size.width)/2
                switch abs(pos-size-x) {
                case let i where i>=10 && i<=15: return 0.1
                default: return 0
                }
            }
        }
        return dist
    }
}
