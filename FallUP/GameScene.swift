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
    private let badWallSize = CGSize(width: 30, height: 75)
    private var gameFrame: CGSize?
    
    //game SKActions
    private var wallAction: SKAction?
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        gameFrame = view.frame.size
        
        initializePermanentObjects()
        
        let moveDistance = CGFloat(self.frame.size.width + 140)
        let moveWalls = SKAction.repeatForever(SKAction.moveBy(x: -moveDistance, y: 0, duration: TimeInterval(0.01 * moveDistance)))
        let removeWalls = SKAction.removeFromParent()
        wallAction  = SKAction.sequence([moveWalls,removeWalls])
        
        let spawnAction = SKAction.run({[weak self = self] in self?.spawnEnemyWalls()})
        let spawnDelay = SKAction.wait(forDuration: TimeInterval(2.0))
        let wallSpawn = SKAction.repeatForever(SKAction.sequence([spawnAction, spawnDelay]))
        run(wallSpawn)
    }
    
    private func initializePermanentObjects(){
        ball = self.childNode(withName: "//ball") as? SKSpriteNode
        ball?.physicsBody?.categoryBitMask = CollisionMasks.ball
        ball?.physicsBody?.collisionBitMask = CollisionMasks.wall |  CollisionMasks.enemy
        ball?.physicsBody?.contactTestBitMask = CollisionMasks.wall | CollisionMasks.enemy
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
    
    private func deactivateAllPermanentObjects(){
        ball?.physicsBody?.affectedByGravity = false
        ball?.physicsBody?.isDynamic = false
    }
    
    //will change later to spawn all enemy types, not just walls
    private func spawnEnemyWalls(){
        let heightDifference = CGFloat((gameFrame?.height)! / 2)
        
        let enemyWallSet = SKNode()
        let enemyWall1 = SKSpriteNode(imageNamed: "botRect")
        enemyWall1.size = badWallSize
        enemyWall1.position = CGPoint(x: (gameFrame?.width)! + 50, y: (gameFrame?.height)!/2 + heightDifference)
        enemyWall1.physicsBody = SKPhysicsBody(rectangleOf: badWallSize)
        enemyWall1.physicsBody?.affectedByGravity = false
        enemyWall1.physicsBody?.isDynamic = false
        enemyWall1.physicsBody?.categoryBitMask = CollisionMasks.enemy
        enemyWall1.physicsBody?.collisionBitMask = CollisionMasks.ball
        enemyWall1.physicsBody?.contactTestBitMask = CollisionMasks.ball
        
        let enemyWall2 = SKSpriteNode(imageNamed: "botRect")
        enemyWall2.size = badWallSize
        enemyWall2.position = CGPoint(x: (gameFrame?.width)! + 50, y: (gameFrame?.height)!/2 - heightDifference)
        enemyWall2.physicsBody?.affectedByGravity = false
        enemyWall2.physicsBody?.isDynamic = false
        enemyWall2.physicsBody?.categoryBitMask = CollisionMasks.enemy
        enemyWall2.physicsBody?.collisionBitMask = CollisionMasks.ball
        enemyWall2.physicsBody?.contactTestBitMask = CollisionMasks.ball
        
        enemyWallSet.addChild(enemyWall1)
        enemyWallSet.addChild(enemyWall2)
        enemyWallSet.zPosition = 0
        
        enemyWallSet.run(wallAction!)
        addChild(enemyWallSet)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let char1 = contact.bodyA.categoryBitMask
        let char2 = contact.bodyB.categoryBitMask
        
        if char1 | char2 == CollisionMasks.ball | CollisionMasks.wall{
            changeBallGravity()
        }
        
        if char1 | char2 == CollisionMasks.ball | CollisionMasks.enemy{
            isPlaying = false
            let label = SKLabelNode(text: "GAME OVER")
            label.fontSize = CGFloat(17)
            label.position = CGPoint(x: (gameFrame?.width)!/2, y: (gameFrame?.height)!/2)
            addChild(label)
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
        changeBallGravity()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if let enemies = self.childNode(withName: "enemyWallSet"){
            if !intersects(enemies){
                enemies.removeFromParent()
            }
        }
    }
}
