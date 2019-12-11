//
//  Hunger.swift
//  2D-Minecraft-Based-Game
//
//  Created by Erik Asbjornson on 11/14/19.
//  Copyright © 2019 Erik Asbjornson. All rights reserved.
//

import SpriteKit
import GameplayKit

extension GameScene {
    
    func hunger(eaten: Int,sat: Decimal) {
        // Called when hunger changes
        
        var name = String()
        var food = Decimal(eaten)
        
        saturation=saturation+sat
        if saturation < 0 {
            food+=saturation
            saturation=0
        }
        
        //changes hunger textures
        for num in 0...9 {
            switch (20-hungerLeft)-food-Decimal(num*2) {
            case let i where i >= 2:
                name =  "empty_hunger"
            case let i where 1 <= i && i < 2:
                name = "half_hunger"
            default:
                name = "full_hunger"
            }
            hunger[num].texture = SKTexture(imageNamed: name)
        }
        
        hungerLeft+=food
        
        //keeps hunger in range of 0-20 and saturation in range of 0-hungerLeft
        if hungerLeft > 20 {hungerLeft = 20}
        if hungerLeft < 0 {hungerLeft = 0}
        if saturation > hungerLeft {saturation = hungerLeft}
    }
    
    func exhaustion(increase: Decimal) {
        // Called when actions that decrease hunger are executed
        
        exhaustion+=increase
        while exhaustion >= 4 {
            if exhaustion >= 4 {
                hunger(eaten: 0,sat: -1)
                exhaustion-=4
            }
        }
    }
    
    func checkHunger() {
        // Called every frame to see if regen needs to happen, sprinting is disabled, or if the player is starving
        
        var time:TimeInterval = 4
        if saturation > 0 {time=0.5}
        
        switch hungerLeft {
        case let i where i > 17:
            if health != 20 {if !(regenTimer?.isValid ?? false) {
                regenTimer = Timer.scheduledTimer(withTimeInterval: time, repeats: false) {(regenTimer) in self.health(lost: -1)}
                regen2Timer = Timer.scheduledTimer(withTimeInterval: time, repeats: false) {(regen2Timer) in self.exhaustion(increase: 6)}
                }
            } else {
                endHungerTimer()
            }
            
        case 0:
            if health > 1 {if regenTimer == nil {
                regenTimer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) {(regenTimer) in self.health(lost: 1)}
                }
            } else {
                endHungerTimer()
            }
            
        default:
            endHungerTimer()
        }
        
        if hungerLeft <= 6 {sprintingEnd()}
    }
    
    func endHungerTimer() {
        // Called to end the heatlh regen and hunger decreasing timers
        
        regenTimer?.invalidate()
        regenTimer = nil
        
        regen2Timer?.invalidate()
        regen2Timer = nil
    }
}
