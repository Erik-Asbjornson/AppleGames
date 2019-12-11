//
//  Controls.swift
//  2D-Minecraft-Based-Game
//
//  Created by Erik Asbjornson on 11/15/19.
//  Copyright © 2019 Erik Asbjornson. All rights reserved.
//

import SpriteKit
import GameplayKit

extension GameScene {
    func showControls() {
        if childNode(withName: "controls text") != nil {
            childNode(withName: "controls text")?.removeFromParent()
            return
        }
        let text = SKLabelNode(text: "The seed only affects terrain not biome layout.\n\nThe controls for movements are arrow keys for left, right, and jump.\nIf you double tap the left or right arrow you will start sprinting which is faster than normal walking, but it consumes hunger.\n\nYou use the left mouse button to break blocks, and you use the right mouse button to place blocks and eat food.\n\nThe e key opens inventory and the q key throws the selected hotbar item out of your hotbar.")
        text.name = "controls text"
        text.position = CGPoint(x: self.size.width/2, y: self.size.height/2-100)
        text.numberOfLines = 3
        text.preferredMaxLayoutWidth = 850
        addChild(text)
    }
}
