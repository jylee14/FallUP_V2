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
    static let bomb:UInt32 = 0x1 << 3
    static let badWall:UInt32 = 0x1 << 4
}

class GameScene: SKScene {
    private var ball: SKSpriteNode?  //player's character
    private var bomb: SKSpriteNode?  //miniature squares that the player needs to avoid
    private var topWall: SKSpriteNode?   //top wall
    private var botWall: SKSpriteNode?   //bottom wall
    private var badWall: SKSpriteNode?   //bad wall that player needs to avoid
    
    private var isBlue = true
    
    /**
     default func provided by XCode
     override func didMove(to view: SKView) {
     
     // Get label node from scene and store it for use later
     self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
     if let label = self.label {
     label.alpha = 0.0
     label.run(SKAction.fadeIn(withDuration: 2.0))
     }
     
     // Create shape node to use during mouse interaction
     let w = (self.size.width + self.size.height) * 0.05
     self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
     
     if let spinnyNode = self.spinnyNode {
     spinnyNode.lineWidth = 2.5
     
     spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
     spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
     SKAction.fadeOut(withDuration: 0.5),
     SKAction.removeFromParent()]))
     }
     }
     */
    
    override func didMove(to view: SKView) {
        ball = self.childNode(withName: "//ball") as? SKSpriteNode
        ball?.physicsBody?.categoryBitMask = CollisionMasks.ball
        ball?.physicsBody?.collisionBitMask = CollisionMasks.wall | CollisionMasks.badWall | CollisionMasks.bomb
        ball?.physicsBody?.contactTestBitMask = CollisionMasks.wall | CollisionMasks.badWall | CollisionMasks.bomb
        
        topWall = self.childNode(withName: "//topWall") as? SKSpriteNode
        topWall?.physicsBody?.categoryBitMask = CollisionMasks.wall
        topWall?.physicsBody?.collisionBitMask = CollisionMasks.ball
        topWall?.physicsBody?.contactTestBitMask = CollisionMasks.ball
        
        botWall = self.childNode(withName: "//botWall") as? SKSpriteNode
        botWall?.physicsBody?.categoryBitMask = CollisionMasks.wall
        botWall?.physicsBody?.collisionBitMask = CollisionMasks.ball
        botWall?.physicsBody?.contactTestBitMask = CollisionMasks.ball
        
        
    }
    
    private func addBall(){
        ball = SKSpriteNode(imageNamed: "blueBall")
        ball?.size = CGSize(width: 60, height: 60)
        ball?.position = CGPoint(x: (self.scene?.size.width)!/4, y: (self.scene?.size.height)! * 3/4)
        ball?.physicsBody = SKPhysicsBody(circleOfRadius: 30)
        ball?.physicsBody?.isDynamic = false
        ball?.physicsBody?.affectedByGravity = false
        
        self.addChild(ball!)
    }
    
    private  func addTopAndBottomWalls(){
        topWall = SKSpriteNode(imageNamed: "blueWall")
        topWall?.position = CGPoint(x: self.frame.width/2, y: self.frame.height - (topWall?.size.height)!)
        topWall?.physicsBody = SKPhysicsBody(rectangleOf: (topWall?.size)!)
        topWall?.physicsBody?.isDynamic = false
        topWall?.physicsBody?.affectedByGravity = false
        
        botWall = SKSpriteNode(imageNamed: "orangeWall")
        botWall?.position = CGPoint(x: self.frame.width/2, y: self.frame.height - (topWall?.size.height)!)
        botWall?.physicsBody = SKPhysicsBody(rectangleOf: (botWall?.size)!)
        botWall?.physicsBody?.isDynamic = false
        botWall?.physicsBody?.affectedByGravity = false
        
        self.addChild(topWall!)
        self.addChild(botWall!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
