//
//  GameOverScene.swift
//  SpriteKitSimpleGame
//
//  Created by Jake Payton on 10/10/14.
//  Copyright (c) 2014 Jake Payton. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    override init( size: CGSize ) {
        
        super.init( size: size )
        
        var bgColor = isDaytime()
            ? SKColor( red: 81.0/255.0, green: 192.0/255.0, blue: 201.0/255.0, alpha: 1.0 )
            : SKColor( red: 19.0/255.0, green: 135.0/255.0, blue: 146.0/255.0, alpha: 1.0 )
        
        self.backgroundColor = bgColor

        let gameOver = SKSpriteNode( imageNamed: "Game_Over" )
        gameOver.position = CGPoint( x: size.width/2, y: size.height/2 )
        gameOver.setScale( 1.5 )
        addChild( gameOver )
        
        runAction( SKAction.sequence( [
            SKAction.waitForDuration( 3.5 ),
            SKAction.runBlock() {
                let reveal = SKTransition.doorsOpenVerticalWithDuration( 1.0 )
                let scene = GameScene( size: size )
                self.view?.presentScene( scene, transition: reveal )
            }
            ] ) )
        
    }
    
    required init( coder aDecoder: NSCoder ) {
        fatalError( "init(coder:) has not been implemented" )
    }
}