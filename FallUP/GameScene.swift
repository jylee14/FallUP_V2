//
//  GameScene.swift
//  FallUP
//
//  Created by Jun Lee on 8/14/17.
//  Copyright © 2017 Jun Lee. All rights reserved.
//

import SpriteKit
import GameplayKit

struct CollisionMasks{
    static let ball:UInt32 = 0x1 << 1
    static let wall:UInt32 = 0x1 << 2
    static let enemy:UInt32 = 0x1 << 3
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    //in game sprites
    private var ball: SKSpriteNode?  //player's character
    private var topWall: SKSpriteNode?   //top wall
    private var botWall: SKSpriteNode?   //bottom wall
    
    private var badWalls: SKNode?   //bad wall that player needs to avoid
    private var bombs: SKNode?  //miniature squares that the player needs to avoid
    
    //game logic variables
    private var isBlue = true
    private var isPlaying = false
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        initializePermanentObjects()
        
        
    }
    
    private func initializePermanentObjects(){
        ball = self.childNode(withName: "//ball") as? SKSpriteNode
        ball?.physicsBody?.categoryBitMask = CollisionMasks.ball
        ball?.physicsBody?.collisionBitMask = CollisionMasks.wall |  CollisionMasks.enemy
        ball?.physicsBody?.contactTestBitMask = CollisionMasks.wall | CollisionMasks.enemy
        
        topWall = self.childNode(withName: "//topWall") as? SKSpriteNode
        topWall?.physicsBody?.categoryBitMask = CollisionMasks.wall
        topWall?.physicsBody?.collisionBitMask = CollisionMasks.ball
        topWall?.physicsBody?.contactTestBitMask = CollisionMasks.ball
        
        botWall = self.childNode(withName: "//botWall") as? SKSpriteNode
        botWall?.physicsBody?.categoryBitMask = CollisionMasks.wall
        botWall?.physicsBody?.collisionBitMask = CollisionMasks.ball
        botWall?.physicsBody?.contactTestBitMask = CollisionMasks.ball
    }
    
    private func deactivateAllPermanentObjects(){
        ball?.physicsBody?.affectedByGravity = false
        ball?.physicsBody?.isDynamic = false
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let char1 = contact.bodyA
        let char2 = contact.bodyB
        
        if char1.categoryBitMask == CollisionMasks.ball {
            if char2.categoryBitMask == CollisionMasks.wall {
                changeBallGravity()
            }else{
                isPlaying = false
            }
        }
    }
    
    private func changeBallGravity(){
        if isBlue{
            ball?.texture = SKTexture(imageNamed: "orangeBall")
            self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 5.0)
            isBlue = false
        }else{
            ball?.texture = SKTexture(imageNamed: "blueBall")
            self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0)
            isBlue = true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isPlaying{
            changeBallGravity()
        }else{
            isPlaying = true
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
