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
    static let passThrough:UInt32 = 0x1 << 5
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    //in game sprites
    private var ball: SKSpriteNode?  //player's character
    private var topWall: SKSpriteNode?  //top wall
    private var botWall: SKSpriteNode?  //bottom wall
    
    private var enemies: SKNode?   //bad wall that player needs to avoid
    private var scoreNode = SKLabelNode()
    
    
    //game logic variables
    private var isBlue = true
    private var isPlaying = false
    private var gameFrame: CGSize?
    private var score:UInt32 = 0   //starts at 0
    
    private let bombSize = CGSize(width: 50, height: 50)
    private let badWallSize = CGSize(width: 50, height: 200)
    
    
    //game SKActions
    private var enemyAction: SKAction?
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        self.scaleMode = .aspectFill  //added to scale to fit
        gameFrame = view.frame.size
        isPlaying = true
        
        scoreNode.color = SKColor.white
        scoreNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 100)
        scoreNode.fontSize = CGFloat(40)
        scoreNode.text = "\(score)"
        scoreNode.zPosition = 5
        addChild(scoreNode)
        
        initializePermanentObjects()
        
        let moveDistance = CGFloat((gameFrame?.width)! + 500)
        let moveEnemies = SKAction.moveBy(x: -moveDistance, y: 0, duration: TimeInterval(2.5))
        let removeEnemies = SKAction.removeFromParent()
        enemyAction  = SKAction.sequence([moveEnemies,removeEnemies])
        
        let spawnAction = SKAction.run({[weak self = self] in self?.spawnEnemyWalls()})
        let spawnDelay = SKAction.wait(forDuration: TimeInterval(1.25))
        let enemySpawn = SKAction.repeatForever(SKAction.sequence([spawnAction, spawnDelay]))
        run(enemySpawn)
        
    }
    
    private func initializePermanentObjects(){
        ball = self.childNode(withName: "//ball") as? SKSpriteNode
        ball?.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        ball?.physicsBody?.isDynamic = true
        ball?.physicsBody?.affectedByGravity = true
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
        enemyAction = SKAction()
    }
    
    //will change later to spawn all enemy types, not just walls
    private func spawnEnemyWalls(){
        enemies = SKNode()
        let randomY = CGFloat(arc4random_uniform(125))
        
        let passNode = SKSpriteNode()   //need to check if the player passes through
        let enemy1 = spawnEnemies(Int(arc4random_uniform(score / 4)))   //bomb or wall?
        let enemy2 = spawnEnemies(Int(arc4random_uniform(score / 4)))   //bomb or wall?
        let enemy3 = spawnEnemies(Int(arc4random_uniform(score / 4)))   //maybe we need the 3rd obj
        
        enemy1.position = CGPoint(x: (gameFrame?.width)! + 50, y: randomY + 170)
        enemy2.position = CGPoint(x: (gameFrame?.width)! + 50, y: randomY - 170)
        enemy3.position = CGPoint(x: (gameFrame?.width)! + 50, y: frame.midY + 50)
        passNode.position = CGPoint(x: enemy1.position.x, y: 0)
        
        passNode.size = CGSize(width: 1, height: (gameFrame?.height)!)
        passNode.physicsBody = SKPhysicsBody(rectangleOf: passNode.size)
        passNode.physicsBody?.isDynamic = false
        passNode.physicsBody?.affectedByGravity = false
        passNode.physicsBody?.categoryBitMask = CollisionMasks.passThrough
        passNode.physicsBody?.collisionBitMask = CollisionMasks.ball
        passNode.physicsBody?.contactTestBitMask = CollisionMasks.ball
        
        enemies?.addChild(enemy1)
        enemies?.addChild(enemy2)
        enemies?.addChild(enemy3)
        enemies?.addChild(passNode)
        enemies?.zPosition = 0
        enemies?.run(enemyAction!)
        addChild(enemies!)
    }
    
    private func spawnEnemies(_ enemyCode: Int)->SKSpriteNode{
        let enemy: SKSpriteNode
        if enemyCode < 2{
            enemy = SKSpriteNode(imageNamed: "bomb")
            enemy.size = bombSize
            enemy.physicsBody = SKPhysicsBody(rectangleOf: bombSize)
        }else{
            enemy = SKSpriteNode(imageNamed: "botRect")
            enemy.size = badWallSize
            enemy.physicsBody = SKPhysicsBody(rectangleOf: badWallSize)
        }
        
        enemy.physicsBody?.isDynamic = false
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.restitution = 0.0
        enemy.physicsBody?.friction = 0.0
        enemy.physicsBody?.linearDamping = 0.0
        enemy.physicsBody?.angularDamping = 0.0
        enemy.physicsBody?.categoryBitMask = CollisionMasks.enemy
        enemy.physicsBody?.collisionBitMask = CollisionMasks.ball
        enemy.physicsBody?.contactTestBitMask = CollisionMasks.ball
        
        return enemy
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let char1 = contact.bodyA
        let char2 = contact.bodyB
        
        if char1.categoryBitMask | char2.categoryBitMask == CollisionMasks.ball | CollisionMasks.wall && isPlaying {
            changeBallGravity()
        }
        
        if char1.categoryBitMask | char2.categoryBitMask == CollisionMasks.ball | CollisionMasks.passThrough && isPlaying {
            score += 1
            scoreNode.text = String(score)
        }
        
        if char1.categoryBitMask | char2.categoryBitMask == CollisionMasks.ball | CollisionMasks.enemy{
            isPlaying = false
            scoreNode.removeFromParent()
    
            self.removeAllActions()
            
            let gameOver = SKLabelNode(text: "GAME OVER!")
            let scoreBoard = SKLabelNode()
            
            gameOver.fontSize = CGFloat(45)
            gameOver.position = CGPoint(x: frame.midX, y: frame.midY + 50)
            scoreBoard.fontSize = CGFloat(45)
            scoreBoard.position = CGPoint(x: frame.midX, y: frame.midY)
            scoreBoard.text = "SCORE: \(score)"
            
            self.addChild(gameOver)
            self.addChild(scoreBoard)
        }
        
    }
    
    private func changeBallGravity(){
        if isBlue{
            ball?.texture = SKTexture(imageNamed: "orangeBall")
            ball?.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 2.0))
            self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 5.0)
            isBlue = false
        }else{
            ball?.texture = SKTexture(imageNamed: "blueBall")
            ball?.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -2.0))
            self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0)
            isBlue = true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isPlaying{
            changeBallGravity()
        }else{
            let fade = SKTransition.fade(withDuration: TimeInterval(1.5))
            let gameScene = SKScene(fileNamed: "GameScene")
            self.view?.presentScene(gameScene!, transition: fade)
            
            score = 0
        }
    }
}
