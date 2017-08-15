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
    static let endWall:UInt32 = 0x1 << 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    //in game sprites
    private var ball: SKSpriteNode?  //player's character
    private var topWall: SKSpriteNode?  //top wall
    private var botWall: SKSpriteNode?  //bottom wall
    private var endWall: SKSpriteNode?  //end of the map 
    
    private var badWalls: SKNode?   //bad wall that player needs to avoid
    private var bombs: SKNode?  //miniature squares that the player needs to avoid
    
    //game logic variables
    private var isBlue = true
    private var isPlaying = false
    private let badWallSize = CGSize(width: 50, height: 200)
    private var gameFrame: CGSize?
    
    //game SKActions
    private var wallAction: SKAction?
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        gameFrame = view.frame.size
        initializePermanentObjects()
        
        let moveDistance = CGFloat((gameFrame?.width)! + 500)
        let moveWalls = SKAction.moveBy(x: -moveDistance, y: 0, duration: TimeInterval(2.5))
        let removeWalls = SKAction.removeFromParent()
        wallAction  = SKAction.sequence([moveWalls,removeWalls])
        
        let spawnAction = SKAction.run({[weak self = self] in self?.spawnEnemyWalls()})
        let spawnDelay = SKAction.wait(forDuration: TimeInterval(2.5))
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
        
        endWall = self.childNode(withName: "//endWall") as? SKSpriteNode
        endWall?.physicsBody?.categoryBitMask = CollisionMasks.endWall
        endWall?.physicsBody?.collisionBitMask = CollisionMasks.enemy
        endWall?.physicsBody?.contactTestBitMask = CollisionMasks.enemy
    }
    
    private func deactivateAllPermanentObjects(){
        ball?.physicsBody?.affectedByGravity = false
        ball?.physicsBody?.isDynamic = false
    }
    
    //will change later to spawn all enemy types, not just walls
    private func spawnEnemyWalls(){
        let randomY = CGFloat(arc4random_uniform(10))
        let enemyWallSet = SKNode()
        enemyWallSet.physicsBody?.affectedByGravity = false
        enemyWallSet.physicsBody?.isDynamic = false
        enemyWallSet.physicsBody?.categoryBitMask = CollisionMasks.enemy
        enemyWallSet.physicsBody?.collisionBitMask = CollisionMasks.ball | CollisionMasks.endWall
        enemyWallSet.physicsBody?.contactTestBitMask = CollisionMasks.ball | CollisionMasks.endWall
        
        let enemyWall1 = SKSpriteNode(imageNamed: "botRect")
        enemyWall1.size = badWallSize
        enemyWall1.position = CGPoint(x: (gameFrame?.width)! + 50, y: randomY + 250)
        enemyWall1.physicsBody = SKPhysicsBody(rectangleOf: badWallSize)
        enemyWall1.physicsBody?.affectedByGravity = false
        enemyWall1.physicsBody?.isDynamic = false
        enemyWall1.physicsBody?.categoryBitMask = CollisionMasks.enemy
        enemyWall1.physicsBody?.collisionBitMask = CollisionMasks.ball | CollisionMasks.endWall
        enemyWall1.physicsBody?.contactTestBitMask = CollisionMasks.ball | CollisionMasks.endWall
        
        let enemyWall2 = SKSpriteNode(imageNamed: "botRect")
        enemyWall2.size = badWallSize
        enemyWall2.position = CGPoint(x: (gameFrame?.width)! + 50, y: randomY)
        enemyWall2.physicsBody?.affectedByGravity = false
        enemyWall2.physicsBody?.isDynamic = false
        enemyWall2.physicsBody?.categoryBitMask = CollisionMasks.enemy
        enemyWall2.physicsBody?.collisionBitMask = CollisionMasks.ball | CollisionMasks.endWall
        enemyWall2.physicsBody?.contactTestBitMask = CollisionMasks.ball | CollisionMasks.endWall
        
        enemyWallSet.addChild(enemyWall1)
        enemyWallSet.addChild(enemyWall2)
        enemyWallSet.zPosition = 0
        
        enemyWallSet.run(wallAction!)
        addChild(enemyWallSet)
    }
    
    private func spawnEnemies(_ enemyCode: Int)->SKSpriteNode{
        let enemy: SKSpriteNode
        if enemyCode == 0{
            enemy = SKSpriteNode(imageNamed: "bomb")
            
        }else{
            enemy = SKSpriteNode(imageNamed: "botRect")
            enemy.size = badWallSize
            enemy.physicsBody = SKPhysicsBody(rectangleOf: badWallSize)
        }
        
        return enemy
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let char1 = contact.bodyA
        let char2 = contact.bodyB
        /*
        if char1.categoryBitMask | char2.categoryBitMask == CollisionMasks.ball | CollisionMasks.wall{
            changeBallGravity()
        }
        */
        if char1.categoryBitMask == CollisionMasks.endWall{
            if let enemies = char1.node?.children{
                for node in enemies{
                    node.removeFromParent()
                }
            }
        }else if char2.categoryBitMask == CollisionMasks.endWall{
            if let enemies = char2.node?.children{
                for node in enemies{
                    node.removeFromParent()
                }
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
        changeBallGravity()
    }
}
