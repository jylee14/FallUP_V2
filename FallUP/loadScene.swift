//
//  LoadScene.swift
//  FallUP
//
//  Created by Jun Lee on 8/15/17.
//  Copyright © 2017 Jun Lee. All rights reserved.
//

import Foundation
import SpriteKit

class LoadScene: SKScene, SKPhysicsContactDelegate{
    private var ball: SKSpriteNode?
    private var topWall: SKSpriteNode?
    private var botWall: SKSpriteNode?
    
    private var isBlue = false
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        initializePermanentObjects()
    }
    
    private func initializePermanentObjects(){
        ball = self.childNode(withName: "//ball") as? SKSpriteNode
        ball?.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        ball?.zPosition = 2
        
        topWall = self.childNode(withName: "//topWall") as? SKSpriteNode
        topWall?.zPosition = 3
        
        botWall = self.childNode(withName: "//botWall") as? SKSpriteNode
        botWall?.zPosition = 3
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.scene is LoadScene{
            if let instruction = childNode(withName: "//instruction"), let logo = childNode(withName: "logo"){
                instruction.removeFromParent()
                logo.removeFromParent()
                
                let fade = SKTransition.fade(withDuration: TimeInterval(1.5))
                let gameScene = SKScene(fileNamed: "GameScene")
                self.view?.presentScene(gameScene!, transition: fade)
            }
        }
    }
}
