//
//  GameViewController.swift
//  FallUP
//
//  Created by Jun Lee on 8/14/17.
//  Copyright © 2017 Jun Lee. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        if let view = self.view as! SKView? {
            // Load the SKScene from 'loadScene.sks'
            if let scene = SKScene(fileNamed: "LoadScene") {
                scene.scaleMode = .aspectFill // Set the scale mode to scale to fit the window
                view.presentScene(scene) // Present the scene
            }
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool { return false }
    override var prefersStatusBarHidden: Bool { return true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .landscape }
}
