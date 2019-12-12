//
//  Health.swift
//  2D-Minecraft-Based-Game
//
//  Created by Erik Asbjornson on 11/14/19.
//  Copyright © 2019 Erik Asbjornson. All rights reserved.
//

import SpriteKit
import GameplayKit

extension GameScene {
    
    func nearDeath() {
        // Called when player has 2 or less full hearts left and shakes the hearts
        
        for heart in hearts {
            let random = TimeInterval.random(in: 0.04...0.06)
            let up = SKAction.move(by: CGVector(dx: 0, dy: 2), duration: random)
            let down = SKAction.move(by: CGVector(dx: 0, dy: -4), duration: random)
            let back = SKAction.move(by: CGVector(dx: 0, dy: 2), duration: random)
            let sequence = SKAction.sequence([up,down,back])
            let forever = SKAction.repeatForever(sequence)
            heart.run(forever, withKey: "shake")
        }
    }
    
    func endNearDeath() {
        // Called when player goes from 2 or less hearts to more than 2 hearts
        
        for num in 0..<hearts.count {
            hearts[num].removeAction(forKey: "shake")
            hearts[num].position = CGPoint(x: (num * iconWidth) + heartsPosX, y: iconPosY)
        }
    }
    
    func flashHearts (_ old: String,_ new: SKSpriteNode){
        // Called when the player's health changes and flashes the difference in health
        
        switch new.name {
        case "empty_heart":
            if old == "half_heart"{
                new.run(SKAction.repeat(SKAction.animate(with: halfLoss, timePerFrame: 0.1), count: 3))}
            else {
                new.run(SKAction.repeat(SKAction.animate(with: fullLoss, timePerFrame: 0.1), count: 3))}
        case "half_heart":
            if old == "empty_heart"{
                new.run(SKAction.repeat(SKAction.animate(with: halfLoss.reversed(), timePerFrame: 0.1), count: 3))}
            else {
                new.run(SKAction.repeat(SKAction.animate(with: halfLoss2, timePerFrame: 0.1), count: 3))}
        default:
            if old == "half_heart"{
                new.run(SKAction.repeat(SKAction.animate(with: halfLoss2.reversed(), timePerFrame: 0.1), count: 3))}
            else {
                new.run(SKAction.repeat(SKAction.animate(with: fullLoss.reversed(), timePerFrame: 0.1), count: 3))}
        }
    }
    
    func damagetaken(){
        // Called when player loses health
        
        damageTimer?.invalidate()
        damageTimer = nil
        let color = SKAction.colorize(with: NSColor.red, colorBlendFactor: 1.0, duration: 0)
        let back = SKAction.colorize(with: NSColor.red, colorBlendFactor: 0, duration: 0)
        player.run(color)
        damageTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) {(damageTimer) in self.player.run(back)}
    }
    
    func health(lost: Int) {
        // Called when player's health changes
        
        //checks how recent last damage was and if new damage is greater
        let now = Date().timeIntervalSince1970
        var damage = lost
        if lost > 0 {
            if now-noDamage < 0.5 {
                if lost > prevDamage {
                    noDamage=now
                    damage-=prevDamage
                    prevDamage=lost
                }
                else {return}
            }
        }
        
        var name: String
        var oldHearts = [String]()
        if damage > 20 {damage = 20}
        
        //sets heart texture
        for num in 0...9 {
            oldHearts.append(hearts[num].name!)
            switch (20-health)+damage-(9-num)*2 {
            case let i where i >= 2:
                name = "empty_heart"
            case 1:
                name = "half_heart"
            default:
                name = "full_heart"
            }
            hearts[num].texture = SKTexture(imageNamed: name)
            hearts[num].name = name
            if oldHearts[num] != hearts[num].name {flashHearts(oldHearts[num],hearts[num])}
        }
        
        //makes health in the range of 0-20
        health-=damage
        if health > 20 {health = 20}
        if health < 0 {health = 0}
        
        //makes hearts shake or stop shaking
        if health <= 4 {nearDeath()} else {endNearDeath()}
        
        //checks if health was lost
        if damage > 0 {damagetaken()}
        
        //if health is 0 die
        if health == 0 {die()}
    }
    
    //empty inventory and hotbar, reset position, reset health, reset hunger
    func die() {
        for i in 0..<hotbar.count {
            let hotToken = hotbar[i].components(separatedBy: ",")
            if hotbar[i] == "" {continue}
            let num = labels[i]
            for _ in 1...num {
                hotDrop(hotToken[0], dead: true)
                decLabel(hotToken, i)
            }
        }
        for i in 0..<inventory.count {
            let hotToken = inventory[i].components(separatedBy: ",")
            if inventory[i] == "" {continue}
            let num = labels[i+9]
            for _ in 1...num {
                hotDrop(hotToken[0], dead: true)
                decLabel(hotToken, i+9)
            }
        }
        player.position = startPos
        health = 20
        hungerLeft = 20
        exhaustion = 20
        saturation = 5
        health(lost: 0)
        hunger(eaten: 0, sat: 0)
    }
}
