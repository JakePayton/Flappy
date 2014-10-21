//
//  GameScene.swift
//  Flappy
//
//  Created by Jake Payton on 10/21/14.
//  Copyright (c) 2014 Detroit Labs. All rights reserved.
//

import UIKit
import SpriteKit

let spaceBetweenPipes = 100.0

struct flappyContactMasks {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Bird      : UInt32 = 0b1       // 1
    static let Pipe      : UInt32 = 0b10      // 2
    static let Ground    : UInt32 = 0b11      // 3
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let imagesAtlas = SKTextureAtlas(named: "FlappyAssets")
    let flappyBird = SKSpriteNode(imageNamed: "Yellow_Bird_Wing_Straight")
   
    override func didMoveToView(view: SKView) {

        addSkyline()
        addForeground()
        addFlappyBird()
        
        physicsWorld.gravity = CGVectorMake(0,-5)
        physicsWorld.contactDelegate = self
        
        // create some pipes with some duratuon
        
        // contact delegate
        
        // game over scene transitions
        
    }

// TODO: This should be refactored into a method to handle both background types
   
    func addSkyline () {
        
        let skylineTexture = imagesAtlas.textureNamed("Day_Background")
        skylineTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        let skylineMove = SKAction.moveByX(-self.frame.width * 2.0, y:0, duration: 15)
        let skylineReset = SKAction.moveByX(self.frame.width * 2.0, y:0 , duration: 0)
        let skylineActions = SKAction.repeatActionForever(SKAction.sequence([skylineMove, skylineReset]))
        
        for i in 0...3 {
            let skyline = SKSpriteNode(texture: skylineTexture)
            skyline.position = CGPointMake(CGFloat(i) * skylineTexture.size().width, self.frame.height * 0.5)
            skyline.runAction(skylineActions);
            skyline.zPosition = -99
            addChild(skyline)
        }
    }
    
    func addForeground() {
    
        let foregroundTexture = imagesAtlas.textureNamed("Bottom_Scroller")
        foregroundTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        let foregroundMove = SKAction.moveByX(-self.frame.width * 2.0, y:0, duration: 5)
        let foregroundReset = SKAction.moveByX(self.frame.width * 2.0, y:0 , duration: 0)
        let foregroundActions = SKAction.repeatActionForever(SKAction.sequence([foregroundMove, foregroundReset]))
        
        for i in 0...3 {
            let foreground = SKSpriteNode(texture: foregroundTexture)
            foreground.position = CGPointMake(CGFloat(i) * foregroundTexture.size().width, foregroundTexture.size().height * 0.5 )
            foreground.runAction(foregroundActions);
            
            foreground.physicsBody = SKPhysicsBody(rectangleOfSize:foreground.size)
            foreground.physicsBody?.dynamic = false
            foreground.physicsBody?.contactTestBitMask = flappyContactMasks.Bird
            foreground.physicsBody?.categoryBitMask = flappyContactMasks.Ground

            
            addChild(foreground)
        }
    }
    
    func addFlappyBird() {
        
        let birdTexture1 = imagesAtlas.textureNamed("Yellow_Bird_Wing_Down")
        let birdTexture2 = imagesAtlas.textureNamed("Yellow_Bird_Wing_Straight")
        let birdTexture3 = imagesAtlas.textureNamed("Yellow_Bird_Wing_Up")
        
        let flapAnimation = SKAction.repeatActionForever(
            SKAction.animateWithTextures([birdTexture1, birdTexture2,  birdTexture3], timePerFrame:0.2)
        )
        flappyBird.runAction(flapAnimation)
        
        flappyBird.position = CGPointMake(self.frame.width * 0.5, self.frame.height * 0.5)
        
        // physics body

        flappyBird.physicsBody = SKPhysicsBody(rectangleOfSize: flappyBird.size)
        flappyBird.physicsBody?.dynamic = true
        flappyBird.physicsBody?.allowsRotation = false
        
        flappyBird.physicsBody?.contactTestBitMask = flappyContactMasks.Pipe | flappyContactMasks.Ground
        flappyBird.physicsBody?.categoryBitMask = flappyContactMasks.Bird
        
        addChild(flappyBird)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        flappyBird.physicsBody?.velocity = CGVectorMake(0,0)
        flappyBird.physicsBody?.applyImpulse(CGVectorMake(0,10))
    }
   
    override func update(currentTime: CFTimeInterval) {
     
        // Count score?
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
    
        var firstObject = contact.bodyA.contactTestBitMask
        var secondObject = contact.bodyB.contactTestBitMask
        
        if ( firstObject == flappyContactMasks.Bird || secondObject == flappyContactMasks.Bird ) {
            
            let loseLabel = SKLabelNode(fontNamed: "Helvetica")
            loseLabel.text = "LOSE"
            
            loseLabel.position = CGPointMake(self.frame.width * 0.5, self.frame.height * 0.5 )
            
            addChild(loseLabel)
        }
    }
}
