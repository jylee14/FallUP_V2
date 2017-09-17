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
    private var ball: SKSpriteNode?         //player
    private var topWall: SKSpriteNode?      //top boundary
    private var botWall: SKSpriteNode?      //bottom boundary
    private var logo: SKSpriteNode?         //logo
    private var instruction: SKLabelNode?   //instruction
    
    private var isBlue = false
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        scene!.anchorPoint = CGPoint(x: 0, y: 0)
        scene!.scaleMode = SKSceneScaleMode.fill   //added to scale to fit, will crash if it fails
        
        initializePermanentObjects()
    }
    
    private func initializePermanentObjects(){
        ball = self.childNode(withName: "//ball") as? SKSpriteNode
        ball?.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        ball?.physicsBody?.categoryBitMask = CollisionMasks.ball
        ball?.physicsBody?.collisionBitMask = CollisionMasks.wall
        ball?.physicsBody?.contactTestBitMask = CollisionMasks.wall
        ball?.zPosition = 2
        
        topWall = self.childNode(withName: "//topWall") as? SKSpriteNode
        topWall?.size = CGSize(width: size.width, height: 30)
        topWall?.position = CGPoint(x: size.width/2, y: size.height)
        topWall?.physicsBody?.categoryBitMask = CollisionMasks.wall
        topWall?.physicsBody?.collisionBitMask = CollisionMasks.ball
        topWall?.physicsBody?.contactTestBitMask = CollisionMasks.ball
        topWall?.zPosition = 3
        
        botWall = self.childNode(withName: "//botWall") as? SKSpriteNode
        botWall?.size = CGSize(width: size.width, height: 30)
        botWall?.position = CGPoint(x: size.width/2, y: 0)
        botWall?.physicsBody?.categoryBitMask = CollisionMasks.wall
        botWall?.physicsBody?.collisionBitMask = CollisionMasks.ball
        botWall?.physicsBody?.contactTestBitMask = CollisionMasks.ball
        botWall?.zPosition = 3
        
        logo = self.childNode(withName: "//logo") as? SKSpriteNode
        logo?.position = CGPoint(x: size.width * 4/5, y: size.height * 3/4)
        logo?.size = CGSize(width: size.width/6, height: size.height/6)
        
        instruction = self.childNode(withName: "instruction") as? SKLabelNode
        instruction?.position = CGPoint(x: size.width/2, y: size.height/4)
        instruction?.fontSize = size.width / CGFloat(20)
    }
    
    
    /*
     * change the gravity of the scene
     */
    private func changeBallGravity(){
        if isBlue{
            ball?.texture = SKTexture(imageNamed: "orangeBall")
            physicsWorld.gravity = CGVector(dx: 0.0, dy: 4.0)
            isBlue = false
        }else{
            ball?.texture = SKTexture(imageNamed: "blueBall")
            physicsWorld.gravity = CGVector(dx: 0.0, dy: -4.0)
            isBlue = true
        }
    }
    
    /*
     * SKPhysicsBody delegate method
     */
    func didBegin(_ contact: SKPhysicsContact) {
        let char1 = contact.bodyA
        let char2 = contact.bodyB
        
        if char1.categoryBitMask | char2.categoryBitMask == CollisionMasks.ball | CollisionMasks.wall{
            changeBallGravity()
        }
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
