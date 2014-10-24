//
//  GameScene.swift
//  Flappy
//
//  Created by Jake Payton on 10/21/14.
//  Copyright (c) 2014 Detroit Labs. All rights reserved.
//

import UIKit
import SpriteKit

let spaceBetweenPipes = 150.0
let imagesAtlas       = SKTextureAtlas(named: "FlappyAssets")

struct flappyContactMasks {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Bird      : UInt32 = 0b1       // 1
    static let Pipe      : UInt32 = 0b10      // 2
    static let Ground    : UInt32 = 0b11      // 3
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var flappyBird:      SKSpriteNode!
    var forwardMovement: SKNode!
    var pipeMovement:    SKNode!

    // MARK: #===== Init =====#

    override func didMoveToView( view: SKView ) {

        physicsWorld.gravity = CGVectorMake(0,-5)
        physicsWorld.contactDelegate = self
        
        self.backgroundColor = SKColor( red: 81.0/255.0, green: 192.0/255.0, blue: 201.0/255.0, alpha: 1.0 )

        forwardMovement = SKNode()
        addChild(forwardMovement)
        
        addSkyline()
        addForeground()
        addFlappyBird()
        
        pipeMovement = SKNode()
        addChild(pipeMovement)
        
        let spawn = SKAction.runBlock({() in self.pipeGenerator()})
        let delay = SKAction.waitForDuration(NSTimeInterval(1.66))
        self.runAction( SKAction.repeatActionForever(SKAction.sequence( [ spawn, delay ] ) ) )
        
        // TODO: track score of pipes passed
        
        forwardMovement.speed = 1.0
        
    }
    
    // MARK: #===== Frame Update =====#
    
    override func update( currentTime: CFTimeInterval ) {
        
        flappyBird.zRotation = self.constrain( -1, maximum: 0.5, attempt: flappyBird.physicsBody!.velocity.dy * ( flappyBird.physicsBody!.velocity.dy < 0 ? 0.005 : 0.002 ) )
        
    }


    // MARK: #===== Sprites =====#

   
    func addSkyline () {

        // TODO: there is a jump between the 3rd and 1st sprite
        
        let skylineTexture           = imagesAtlas.textureNamed( "Day_Background" )
        skylineTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        let skylineMove    = SKAction.moveByX( -self.frame.width * 2.0, y: 0, duration: 15 )
        let skylineReset   = SKAction.moveByX( self.frame.width * 2.0, y: 0 , duration: 0 )
        let skylineActions = SKAction.repeatActionForever( SKAction.sequence( [skylineMove, skylineReset] ) )
        
        for i in 0...3 {
            let skyline = SKSpriteNode( texture: skylineTexture )
            skyline.position = CGPointMake( CGFloat(i) * skylineTexture.size().width * 0.99 , self.frame.height * 0.5 )
            skyline.runAction( skylineActions );
            forwardMovement.addChild( skyline )
        }
    }
    
    func addForeground() {
    
        let foregroundTexture = imagesAtlas.textureNamed("Bottom_Scroller")
        foregroundTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        let foregroundMove = SKAction.moveByX( -self.frame.width * 2.0, y:0, duration: 5 )
        let foregroundReset = SKAction.moveByX( self.frame.width * 2.0, y:0 , duration: 0 )
        let foregroundActions = SKAction.repeatActionForever( SKAction.sequence( [foregroundMove, foregroundReset] ) )
        
        for i in 0...3 {
            let foreground = SKSpriteNode(texture: foregroundTexture)
            foreground.position = CGPointMake( CGFloat(i) * foregroundTexture.size().width, foregroundTexture.size().height * 0.5 )
            foreground.runAction(foregroundActions);
            
            foreground.physicsBody = SKPhysicsBody(rectangleOfSize:foreground.size)
            foreground.physicsBody?.dynamic = false
            foreground.physicsBody?.contactTestBitMask = flappyContactMasks.Bird
            foreground.physicsBody?.categoryBitMask = flappyContactMasks.Ground

            forwardMovement.addChild(foreground)
        }
    }
    
    func addFlappyBird() {
        
        let birdTexture1 = imagesAtlas.textureNamed( "Yellow_Bird_Wing_Down" )
        let birdTexture2 = imagesAtlas.textureNamed( "Yellow_Bird_Wing_Straight" )
        let birdTexture3 = imagesAtlas.textureNamed( "Yellow_Bird_Wing_Up" )
        
        flappyBird          = SKSpriteNode( texture : birdTexture1 )
        flappyBird.position = CGPointMake( self.frame.width * 0.5, self.frame.height * 0.5 )
        
        flappyBird.physicsBody                     = SKPhysicsBody( rectangleOfSize : flappyBird.size )
        flappyBird.physicsBody?.dynamic            = true
        flappyBird.physicsBody?.allowsRotation     = false
        flappyBird.physicsBody?.contactTestBitMask = flappyContactMasks.Pipe | flappyContactMasks.Ground
        flappyBird.physicsBody?.categoryBitMask    = flappyContactMasks.Bird

        
        let flapAnimation = SKAction.repeatActionForever(
            SKAction.animateWithTextures([birdTexture1, birdTexture2,  birdTexture3], timePerFrame:0.2)
        )

        flappyBird.runAction( flapAnimation )
        
        forwardMovement.addChild(flappyBird)
    }
    
    func addPhysicsBodyToPipeNode( spriteNode: SKSpriteNode ) {
        spriteNode.physicsBody                     = SKPhysicsBody( rectangleOfSize : spriteNode.size )
        spriteNode.physicsBody?.dynamic            = true
        spriteNode.physicsBody?.allowsRotation     = false
        spriteNode.physicsBody?.contactTestBitMask = flappyContactMasks.Bird
        spriteNode.physicsBody?.categoryBitMask    = flappyContactMasks.Pipe
    }
    
    func addActionsToPipeNode( spriteNode: SKSpriteNode ) {
        
        let move = SKAction.moveByX( -self.frame.width * 2.0, y:0, duration: 5 )
        let remove = SKAction.removeFromParent()
        let actions = SKAction.repeatActionForever( SKAction.sequence( [ move, remove ] ) )
        
        spriteNode.runAction( actions )
    }
    
    func pipeGenerator() {
        
        let topPipe = SKSpriteNode(texture: imagesAtlas.textureNamed("Downward_Green_Pipe") )
        let bottomPipe = SKSpriteNode(texture: imagesAtlas.textureNamed("Upward_Green_Pipe") )
        
        topPipe.position = CGPointMake( self.frame.width * 2.0, self.frame.height * 0.5 )
        bottomPipe.position = CGPointMake( self.frame.width * 2.0, self.frame.height * 0.5 )
        
        addPhysicsBodyToPipeNode( topPipe )
        addPhysicsBodyToPipeNode( bottomPipe )
        
        addActionsToPipeNode( topPipe )
        addActionsToPipeNode( bottomPipe )
        
        pipeMovement.addChild( topPipe )
        pipeMovement.addChild( bottomPipe )
        
    }
    
    // MARK: #===== Touch =====#
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        flappyBird.physicsBody?.velocity = CGVectorMake( 0, 0 )
        
        flappyBird.physicsBody?.applyImpulse( CGVectorMake( 0, 15 ) )
    }
   
    // MARK: #===== Collision =====#
    
    func didBeginContact(contact: SKPhysicsContact) {
    
        var firstObject  = contact.bodyA.categoryBitMask
        var secondObject = contact.bodyB.categoryBitMask
        
        if ( firstObject == flappyContactMasks.Bird || secondObject == flappyContactMasks.Bird ) {
            // TODO: do something when a bird collides with the ground or a pipe, gameOver scene and transition?
            pipeMovement.speed = 0;
            forwardMovement.speed = 0;
            backgroundColor = .redColor()
        }
    }
    
    // MARK: #===== Helpers =====#
    
    func constrain( minimum: CGFloat, maximum: CGFloat, attempt: CGFloat ) -> CGFloat {
        return max( minimum, min( maximum, attempt ) )
    }

}
