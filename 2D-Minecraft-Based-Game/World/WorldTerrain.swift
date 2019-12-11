//
//  WorldTerrain.swift
//  2D-Minecraft-Based-Game
//
//  Created by Erik Asbjornson on 11/14/19.
//  Copyright © 2019 Erik Asbjornson. All rights reserved.
//

import SpriteKit
import GameplayKit

extension GameScene {
    
    struct BiomeBlocks {
        var biome = "Plains"
        var top = "Grass"
        var top1 = "Dirt"
        var topSpot: String?
        var lower = "Stone"
        var lowerSpot = ["Dirt","Gravel"]
        var ores = ["Coal": [18.6,0,128], "Iron": [11.2,0,64], "Redstone": [2.9,0,16], "Gold": [1.0,0,32], "Diamond": [0.4,0,16], "Lapis": [0.5,0,32]]
        var avgHeight = 65
        var variance: Float = 2.0
    }
    
    //creates noise map for terrain
    func makeNoiseMap(columns: Int) -> GKNoiseMap {
        let source = GKPerlinNoiseSource()
        source.persistence = 0.8
        source.seed = seed
        
        let noise = GKNoise(source)
        let size = vector2(1.0, 1.0)
        let origin = vector2(0.0, 0.0)
        let sampleCount = vector2(Int32(columns), Int32(1))
        
        return GKNoiseMap(noise, size: size, origin: origin, sampleCount: sampleCount, seamless: true)
    }
    
    //sets biome parameters
    func biomes() {
        //let biomeID = [0,0,0,0,1,2,3,4].randomElement()!
        let biomeID = Int.random(in: 1...4)
        switch biomeID {
            /*case 0:
             biomeBlocks.biome = "ocean"
             biomeBlocks.top = "Gravel"
             biomeBlocks.top1 = "Gravel"
             biomeBlocks.topSpot = "Clay"
             biomeBlocks.lower = "Stone"
             biomeBlocks.lowerSpot = ["Dirt","Gravel"]
             biomeBlocks.ores = ["Coal": [18.6,0,128], "Iron": [11.2,0,64], "Redstone": [2.9,0,16], "Gold": [1.0,0,32], "Diamond": [0.4,0,16], "Lapis": [0.5,0,32]]
             biomeBlocks.avgHeight = 45
             biomeBlocks.variance = 2.0*/
        case 1:
            biomeBlocks.biome = "Plains"
            biomeBlocks.top = "Grass"
            biomeBlocks.top1 = "Dirt"
            biomeBlocks.topSpot = nil
            biomeBlocks.lower = "Stone"
            biomeBlocks.lowerSpot = ["Dirt","Gravel"]
            biomeBlocks.ores = ["Coal": [18.6,0,128], "Iron": [11.2,0,64], "Redstone": [2.9,0,16], "Gold": [1.0,0,32], "Diamond": [0.4,0,16], "Lapis": [0.5,0,32]]
            biomeBlocks.avgHeight = 65
            biomeBlocks.variance = 2.0
        case 2:
            biomeBlocks.biome = "desert"
            biomeBlocks.top = "Sand"
            biomeBlocks.top1 = "Sandstone"
            biomeBlocks.topSpot = nil
            biomeBlocks.lower = "Stone"
            biomeBlocks.lowerSpot = ["Dirt","Gravel"]
            biomeBlocks.ores = ["Coal": [18.6,0,128], "Iron": [11.2,0,64], "Redstone": [2.9,0,16], "Gold": [1.0,0,32], "Diamond": [0.4,0,16], "Lapis": [0.5,0,32]]
            biomeBlocks.avgHeight = 65
            biomeBlocks.variance = 2.0
        case 3:
            biomeBlocks.biome = "mountains"
            biomeBlocks.top = "Grass"
            biomeBlocks.top1 = "Dirt"
            biomeBlocks.topSpot = nil
            biomeBlocks.lower = "Stone"
            biomeBlocks.lowerSpot = ["Dirt","Gravel"]
            biomeBlocks.ores = ["Coal": [18.6,0,128], "Iron": [11.2,0,64], "Redstone": [2.9,0,16], "Gold": [1.0,0,32], "Diamond": [0.4,0,16], "Lapis": [0.5,0,32]]
            biomeBlocks.avgHeight = 80
            biomeBlocks.variance = 15
        case 4:
            biomeBlocks.biome = "forest"
            biomeBlocks.top = "Grass"
            biomeBlocks.top1 = "Dirt"
            biomeBlocks.topSpot = nil
            biomeBlocks.lower = "Stone"
            biomeBlocks.lowerSpot = ["Dirt","Gravel"]
            biomeBlocks.ores = ["Coal": [18.6,0,128], "Iron": [11.2,0,64], "Redstone": [2.9,0,16], "Gold": [1.0,0,32], "Diamond": [0.4,0,16], "Lapis": [0.5,0,32]]
            biomeBlocks.avgHeight = 65
            biomeBlocks.variance = 2.0
            /*case 5:
             biomeBlocks.biome = "taiga"
             biomeBlocks.top = "Grass_snow"
             case 6:
             biomeBlocks.biome = "swamp"
             biomeBlocks.avgHeight = 64
             case 7:
             biomeBlocks.biome = "lake"
             biomeBlocks.top = "Gravel"
             biomeBlocks.top1 = "Gravel"
             biomeBlocks.topSpot = "Clay"*/
        case 8:
            biomeBlocks.biome = "nether"
            biomeBlocks.top = "Netherack"
            biomeBlocks.top1 = "Netherack"
            biomeBlocks.lower = "Netherack"
            biomeBlocks.lowerSpot = ["Soul_Sand","Gravel"]
            biomeBlocks.ores = ["Quartz": [11.2,7,117]]
        case 9:
            biomeBlocks.biome = "the_end"
            biomeBlocks.top = "End_Stone"
            biomeBlocks.top1 = "End_Stone"
            biomeBlocks.lower = "End_Stone"
            biomeBlocks.lowerSpot = []
            biomeBlocks.ores = [:]
        default:
            biomeBlocks.biome = "plains"
        }
        biome.append(biomeBlocks.biome)
        //if ocean replace air below 63 with water, lower height average to 45, border of sand?
        //if plains multiply noise by lower number? and few to no trees
        //if desert replace dirt with sand, stone with sand stone, no trees
        //if mountains multiply noise by higher number, increase average height 15
        //if forest many trees
        //if taiga same as forest but different trees and snow
        //if swamp same as forest but replace air below 63 with water, average height 64
        //if lake random place in biome left side same as left biome, right side same as right biome
        //if nether replace stone with netherack, replace ore with quartz, add glowstone, giant cave system
        //if end make floating islands and replace stone with endstone
    }
    
    func createGrid(x: Int,y: Int) {
        //this method creates the terrain
        //x-max = 475
        //y-max = 350
        let noise = makeNoiseMap(columns: blockscol)
        var name = String()
        for col in 0..<blockscol {
            blocksName.append([""])
            if col % biomeSize == 0 {biomes()}
            if biomeBlocks.biome == "mountains" {
                biomeBlocks.variance = min(Float(biomeSize+1)-2.0*abs(Float(col % biomeSize) - Float((biomeSize-1))/2),8)
            }
            for row in blocksrow-128...blocksrow {
                if noise.value(at: vector2(Int32(col),Int32(0)))*biomeBlocks.variance+Float(row) < 0 {name=""} else {
                    switch noise.value(at: vector2(Int32(col),Int32(0)))*biomeBlocks.variance+Float(row) {
                    case let i where i > 3:
                        name = ores(row)
                    default:
                        if nodes(at: CGPoint(x: x + (col * blockSize), y: y - (row-1) * blockSize)).count > 0
                        {name = biomeBlocks.top1} else {name = biomeBlocks.top}
                    }
                    addBlock(image: name,x,y,row,col)
                }
                if name == "" {blocksName[col].append(name)}
                else {blocksName[col].append(name+",\(col),\(row)")}
            }
        }
        trees(x, y, noise)
    }
    
    //creates the blocks
    func addBlock(image name: String,_ xOffset: Int,_ yOffset: Int,_ row: Int,_ col: Int,_ z: CGFloat = 1,_ physics: Bool = true) {
        let item = SKSpriteNode(imageNamed: name)
        item.name = name+",\(col),\(row)"
        item.position = CGPoint(x: xOffset + (col * blockSize), y: yOffset - (row * blockSize))
        item.zPosition = z
        addChild(item)
        item.scale(to: CGSize(width: blockSize, height: blockSize))
        if physics {
            item.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: blockSize, height: blockSize), center: CGPoint.zero)
            item.physicsBody?.isDynamic = false
            item.physicsBody?.restitution = 0
        }
    }
    
    //decides which if stone or an ore will be placed
    func ores(_ row: Int) -> String{
        let rand = Int.random(in: 1...100)
        let ore: Int
        switch row {
        case let i where i >= blocksrow-16: ore = 4
        case let i where i >= blocksrow-32: ore = 3
        case let i where i >= blocksrow-64: ore = 2
        default: ore = 1
        }
        switch (rand,ore) {
        case let i where 2 <= i.0 && i.0 <= 16 && i.1 >= 4: return "Redstone"
        case let i where i.0 == 1 && i.1 >= 3: return "Gold"
        case let i where 17 <= i.0 && i.0 <= 41 && i.1 >= 1: return "Coal"
        default: return "Stone"
        }
    }
    
    //creates trees
    func trees(_ x: Int,_ y: Int,_ noise: GKNoiseMap) {
        var i = -1
        var biomeName = ""
        var dist = Int()
        for col in 0..<blockscol {
            if dist == 0 {
                dist = [4,5,5,6,6,6,6,7,7,8].randomElement()!
                if biomeName == "desert" {dist*=2}
            }
            if col % biomeSize == 0 {
                i+=1
                biomeName = biome[i]
            }
            if !["forest", "desert"].contains(biomeName) {continue}
            dist-=1
            if dist == 0 {
                for row in blocksrow-128 ... blocksrow {
                    if  blocksName[col][row+65] != "" {
                        if biomeName == "desert" {addBlock(image: "Deadbush", x, y, row-1, col, 1, false)}
                        else {addTree(x,y,row-1,col)}
                        break
                    }
                }
            }
        }
    }
    
    //creates a tree
    func addTree(_ xOffset: Int,_ yOffset: Int,_ row: Int,_ col: Int) {
        let height = Int.random(in: 4...6)
        for i in 0..<height {
            addBlock(image: "Wood", xOffset, yOffset, row-i, col, 1, false)
        }
        for i in 0...2 {
            for j in -i...i {
                addBlock(image: "Leaves", xOffset, yOffset, row-height+i, col+j, 2, false)
            }
        }
        for i in -2...2 {
            addBlock(image: "Leaves", xOffset, yOffset, row-height+3, col+i, 2, false)
        }
    }
    
}
