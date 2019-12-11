//
//  ViewController.swift
//  2D-Minecraft-Based-Game
//
//  Created by Erik Asbjornson on 9/9/19.
//  Copyright © 2019 Erik Asbjornson. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {
    
    //make it so gamescene objects can be used
    var gameScene = GameScene()
    
    //initialize buttons
    let play = NSButton()
    let controls = NSButton()
    let quit = NSButton()
    
    //initialize seed text field
    var seed = NSTextField(frame: NSRect(x: 150, y: 230, width: 500, height: 40))
    
    //array for all NSObjects on main menu screen
    var items = [AnyObject]()
    
    @IBOutlet var skView: SKView!
    
    @objc func playPressed(button:NSButton) {
        
        //remove NSObjects
        for item in items {item.removeFromSuperview()}
        
        //if number entered into seed field use it for the seed
        if var num = Int(seed.stringValue) {
            num = num % 2147483648
            gameScene.seed = Int32(num)+Int32(-2147483648)
        }
        
        //start game
        gameScene.inGame = true
    }
    
    @objc func controlsPressed(button:NSButton) {
        
        //remove NSObjects
        for item in items {item.removeFromSuperview()}
        
        //remove title and fine print
        gameScene.title.removeFromParent()
        gameScene.finePrint.removeFromParent()
        
        //show controls
        gameScene.showControls()
    }
    
    //exit game when quit button is pressed
    @objc func quitPressed(button:NSButton) {exit(0)}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.skView {
            // Load the SKScene as view size
            let scene = GameScene(size: view.bounds.size)
            gameScene = scene
            scene.size = CGSize(width: 950, height: 700)
            // Set the scale mode to scale to fit the window
            // Leave as aspectFill until find way to make aspectFit look better
            scene.scaleMode = .aspectFill
            
            items = [play, controls, quit, seed]
            
            //(800,600) is what the cordinates are based on
            //create buttons
            Button(button: play, position: NSPoint(x: 150, y: 280), size: NSSize(width: 500, height: 40), color: NSColor.gray, text: "Play Game", action: #selector(playPressed))
            //Button(button: options, position: NSPoint(x: 150, y: 180), size: NSSize(width: 245, height: 40), color: NSColor.gray, text: "Options...", action: #selector(controlsPressed))
            Button(button: quit, position: NSPoint(x: 150, y: 180), size: NSSize(width: 500, height: 40), color: NSColor.gray, text: "Quit Game", action: #selector(quitPressed))
            
            //create textfield
            seed.font = NSFont(name: "minecraft", size: 20)
            seed.placeholderString = "Leave blank for a random seed"
            seed.formatter = OnlyIntegerFormatter()
            view.addSubview(seed)
            
            // Present the scene
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            //view.showsFPS = true
            //view.showsNodeCount = true
            //view.showsDrawCount = true
            //view.showsPhysics = true
        }
    }
    
    //make it so window can't be resized because it does not look good
    override func viewDidAppear() {self.view.window?.styleMask.remove(.resizable)}
}

