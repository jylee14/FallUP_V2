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
        
        print("LOADSCENE LOADED")
        initializePermanentObjects()
        
    }
    
    private func initializePermanentObjects(){
        ball = self.childNode(withName: "//ball") as? SKSpriteNode
        ball?.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        ball?.physicsBody?.isDynamic = true
        ball?.physicsBody?.affectedByGravity = true
        ball?.physicsBody?.categoryBitMask = CollisionMasks.ball
        ball?.physicsBody?.collisionBitMask = CollisionMasks.wall
        ball?.physicsBody?.contactTestBitMask = CollisionMasks.wall
        ball?.zPosition = 2
        
        topWall = self.childNode(withName: "//topWall") as? SKSpriteNode
        topWall?.physicsBody?.categoryBitMask = CollisionMasks.wall
        topWall?.physicsBody?.collisionBitMask = CollisionMasks.ball
        topWall?.physicsBody?.contactTestBitMask = CollisionMasks.ball
        topWall?.zPosition = 3
        
        botWall = self.childNode(withName: "//botWall") as? SKSpriteNode
        botWall?.physicsBody?.categoryBitMask = CollisionMasks.wall
        botWall?.physicsBody?.collisionBitMask = CollisionMasks.ball
        botWall?.physicsBody?.contactTestBitMask = CollisionMasks.ball
        botWall?.zPosition = 3
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        changeBallGravity()
    }
    
    private func changeBallGravity(){
        if isBlue{
            ball?.texture = SKTexture(imageNamed: "orangeBall")
            ball?.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 2.5))
            self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 5.0)
            isBlue = false
        }else{
            ball?.texture = SKTexture(imageNamed: "blueBall")
            ball?.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -2.5))
            self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0)
            isBlue = true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.scene is LoadScene{
            if let instruction = childNode(withName: "//instruction"), let logo = childNode(withName: "logo"){
                instruction.removeFromParent()
                logo.removeFromParent()
                
                let gameScene = SKScene(fileNamed: "GameScene")
                self.view?.presentScene(gameScene)
            }
        }
    }
}
