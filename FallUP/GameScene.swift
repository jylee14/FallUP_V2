//
//  GameScene.swift
//  FallUP
//
//  Created by Jun Lee on 8/14/17.
//  Copyright © 2017 Jun Lee. All rights reserved.
//

import SpriteKit
import GameplayKit

/* struct that contains the collision masks for in-game objects */
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
    private var isBlue = true   //determines the gravity of the ball object
    private var isPlaying = false   //is the game still going
    private var score:UInt32 = 0   //starts at 0
    
    private var bombSize: CGSize!
    private var badWallSize: CGSize!
    
    
    //game SKActions
    private var enemyAction: SKAction?
    
    /* this scene came into existence */
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        scene!.anchorPoint = CGPoint(x: 0, y: 0)    //origin is at bottom left
        scene!.scaleMode = SKSceneScaleMode.fill    //added to scale to fit, will crash if it fails
        
        let bombSide = size.height / 8.5
        let wallHeight = size.height / 3.25
        bombSize = CGSize(width: bombSide, height: bombSide)
        badWallSize = CGSize(width: bombSide, height: wallHeight)
        
        isPlaying = true
        
        scoreNode.color = SKColor.white
        scoreNode.position = CGPoint(x: size.width/2, y: size.height * 3/4)
        scoreNode.fontSize = CGFloat(40)
        scoreNode.text = "\(score)"
        scoreNode.zPosition = 5
        addChild(scoreNode)
        
        initializePermanentObjects()
        
        let moveDistance = CGFloat(size.width + 500)
        let moveEnemies = SKAction.moveBy(x: -moveDistance, y: 0, duration: TimeInterval(2.75 - 0.00875 * Double(score)))
        let removeEnemies = SKAction.removeFromParent()
        enemyAction  = SKAction.sequence([moveEnemies,removeEnemies])
        
        let spawnAction = SKAction.run({[weak self = self] in self?.spawnEnemyObjects()})
        let spawnDelay = SKAction.wait(forDuration: TimeInterval(1.25))
        let enemySpawn = SKAction.repeatForever(SKAction.sequence([spawnAction, spawnDelay]))
        run(enemySpawn)
    }
    
    /*
     * initialize the properties of the in-game permanent objects and place them in appropriate
     * position within the scene based on the size of the device that is playing the game
     */
    private func initializePermanentObjects(){
        let ballSize = size.width/20
        ball = self.childNode(withName: "//ball") as? SKSpriteNode
        ball?.size = CGSize(width: ballSize, height: ballSize)
        ball?.position = CGPoint(x: size.width/8, y: size.height * 3/4)
        ball?.physicsBody = SKPhysicsBody(circleOfRadius: ballSize/2)
        ball?.physicsBody?.isDynamic = true
        ball?.physicsBody?.affectedByGravity = true
        ball?.physicsBody?.categoryBitMask = CollisionMasks.ball
        ball?.physicsBody?.collisionBitMask = CollisionMasks.wall |  CollisionMasks.enemy
        ball?.physicsBody?.contactTestBitMask = CollisionMasks.wall | CollisionMasks.enemy
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
    }
    
    /*
     * function that gets called to spawn different enemy objects in the game
     * along with invisible line that tracks the score
     */
    private func spawnEnemyObjects(){
        let startingX = size.width + 50         //starting point for all the spawned nodes
        let coinFlip1 = arc4random_uniform(2)    //offset determination
        let coinFlip2 = arc4random_uniform(2)    //offset determination
        let offset1 = CGFloat(arc4random_uniform(UInt32(size.height/4))) - size.height/8   //how much the spawned enemy objects will move in y-axis
        let offset2 = CGFloat(arc4random_uniform(UInt32(size.height/4))) - size.height/8   //how much the spawned enemy objects will move in y-axis
        
        let passNode = spawnDetector()  //get the detectorNode
        let enemy1 = spawnEnemies(Int(arc4random_uniform(score / 5)))   //bomb or wall?
        let enemy2 = spawnEnemies(Int(arc4random_uniform(score / 5)))   //bomb or wall?
        
        let yPosition1 = size.height/4 + (coinFlip1 == 1 ? +offset1 : -offset1)     //position for enemy1 will be in the bottom half of the screen
        let yPosition2 = size.height * 3/4 + (coinFlip2 == 1 ? +offset2 : -offset2) //position for enemy2 will be in the top half of the screen
        
        enemy1.position = CGPoint(x: startingX, y: yPosition1)
        enemy2.position = CGPoint(x: startingX, y: yPosition2)
        passNode.position = CGPoint(x: startingX, y: size.height/2)
        
        enemies = SKNode()  //node to store all the spawned enemies
        enemies?.addChild(enemy1)
        enemies?.addChild(enemy2)
        
        if enemy1.size != badWallSize && enemy2.size != badWallSize { //maybe we need the 3rd obj
            if arc4random_uniform(score) > 8 { //lets make the 3rd obj random based on score.
                if abs(yPosition1 - yPosition2) > (4 * bombSize.height){ //if the difference in position is greater than k bomb objects, add the 3rd
                    let enemy3 = spawnEnemies(0)    //if there's a 3rd object, its going to be a bomb object
                    let offset = CGFloat(arc4random_uniform(35))
                    let coinFlip = arc4random_uniform(2)    //offset determination
                    enemy3.position = CGPoint(x: size.width + 50, y: size.width/2 + (coinFlip == 1 ? offset : -offset))
                    enemies?.addChild(enemy3)
                }
            }
        }
        
        enemies?.zPosition = 0  //these items are going to be in the far back
        enemies?.addChild(passNode)
        enemies?.run(enemyAction!)
        addChild(enemies!)
    }
    
    /*
     * spawn the detector node that runs through the vertical space of the game and will increment the score when it detects
     * collision with the ball object
     */
    private func spawnDetector()->SKSpriteNode{
        let passNode = SKSpriteNode()   //need to check if the player passes through
        passNode.size = CGSize(width: 1, height: size.height)
        passNode.physicsBody = SKPhysicsBody(rectangleOf: passNode.size)
        passNode.physicsBody?.isDynamic = false
        passNode.physicsBody?.affectedByGravity = false
        passNode.physicsBody?.categoryBitMask = CollisionMasks.passThrough
        passNode.physicsBody?.collisionBitMask = CollisionMasks.ball
        passNode.physicsBody?.contactTestBitMask = CollisionMasks.ball
        
        return passNode
    }
    
    /*
     * function that actually does the spawning based on random number that gets passed into the function
     * this will spawn the appropriate enemy object as well as setting the physics body and the sizes of the objects
     * before passing the object back to the calling function
     *
     * @param: _ enemyCode: Int - determines if the enemy to be spawned is bomb or wall. depends on user's score
     * @return: SKSpriteNode - initialized enemy object
     */
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
    
    /*
     * SKPhysicsBody delegate method
     */
    func didBegin(_ contact: SKPhysicsContact) {
        let char1 = contact.bodyA
        let char2 = contact.bodyB
        
        //wall and ball collision
        if char1.categoryBitMask | char2.categoryBitMask == CollisionMasks.ball | CollisionMasks.wall && isPlaying {
            changeBallGravity()
        }
        
        //ball and score node collision
        if char1.categoryBitMask | char2.categoryBitMask == CollisionMasks.ball | CollisionMasks.passThrough && isPlaying {
            score += 1
            scoreNode.text = String(score)
        }
        
        //ball and enemy collision
        if char1.categoryBitMask | char2.categoryBitMask == CollisionMasks.ball | CollisionMasks.enemy{
            if isPlaying { cleanUpWalls() }
            isPlaying = false
            scoreNode.removeFromParent()
            
            self.removeAllActions()
            
            let gameOver = SKLabelNode(text: "GAME OVER!")
            let scoreBoard = SKLabelNode()
            
            gameOver.fontSize = CGFloat(45)
            gameOver.position = CGPoint(x: size.width/2, y: size.height/2 + 50)
            
            scoreBoard.fontSize = CGFloat(45)
            scoreBoard.position = CGPoint(x: size.width/2, y: size.height/2)
            scoreBoard.text = "SCORE: \(score)"
            
            self.addChild(gameOver)
            self.addChild(scoreBoard)
        }
    }
    
    /*
     * function that gets called after the game is over
     * spawns walls that will sweep through everything in the scene
     */
    private func cleanUpWalls(){
        let cleanUpWall = SKNode()
        let cleanUp1 = spawnEnemies(Int.max)
        let cleanUp2 = spawnEnemies(Int.max)
        cleanUp1.position = CGPoint(x: size.width + 50, y: size.height/2 + 125)
        cleanUp2.position = CGPoint(x: size.width + 50, y: size.height/2 - 125)
        
        cleanUpWall.addChild(cleanUp1)
        cleanUpWall.addChild(cleanUp2)
        cleanUpWall.run(enemyAction!)
        addChild(cleanUpWall)
    }
    
    /*
     * change the gravity of the scene
     */
    private func changeBallGravity(){
        if isBlue{
            ball?.texture = SKTexture(imageNamed: "orangeBall")
            ball?.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 1.0))
            physicsWorld.gravity = CGVector(dx: 0.0, dy: +5.0)
            isBlue = false
        }else{
            ball?.texture = SKTexture(imageNamed: "blueBall")
            ball?.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -1.0))
            physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0)
            isBlue = true
        }
    }
    
    //SKScene override function. detects touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isPlaying{
            changeBallGravity()
        }else{
            let fade = SKTransition.fade(withDuration: TimeInterval(1.5))
            let loadScene = SKScene(fileNamed: "LoadScene")
            self.view?.presentScene(loadScene!, transition: fade)
            
            score = 0
        }
    }
}
