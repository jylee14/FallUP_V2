//
//  loadScene
//  FallUP
//
//  Created by Jun Lee on 8/14/17.
//  Copyright © 2017 Jun Lee. All rights reserved.
//

import SpriteKit

class loadScene: SKScene, SKPhysicsContactDelegate {
    //in game sprites
    private var ball: SKSpriteNode?  //player's character
    private var topWall: SKSpriteNode?  //top wall
    private var botWall: SKSpriteNode?  //bottom wall
    
    //game logic variables
    private var isBlue = true
    private var gameFrame: CGSize?
    
    override func didMove(to view: SKView) {
        print("LOADSCENE LOADED")
        
        self.physicsWorld.contactDelegate = self
        self.scaleMode = .aspectFill  //added to scale to fit
        gameFrame = view.frame.size
        
        let scoreNode = SKLabelNode()
        scoreNode.color = SKColor.white
        scoreNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 100)
        scoreNode.fontSize = CGFloat(40)
        scoreNode.text = "0"
        addChild(scoreNode)
        
        initializePermanentObjects()
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
        if let instruction = childNode(withName: "//instruction"){
            let fade = SKAction.fadeIn(withDuration: TimeInterval(1.5))
            
            instruction.run(fade){
                let gameScene = SKScene(fileNamed: "GameScene")
                self.view?.presentScene(gameScene)
            }
            
        }
    }
}
