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
        
        guard let view = self.view as? SKView else {
            print("Error: View is not an SKView")
            return
        }
        
        // Load the SKScene from 'loadScene.sks'
        guard let scene = SKScene(fileNamed: "LoadScene") else {
            print("Error: Could not load LoadScene")
            return
        }
        
        scene.scaleMode = .fill // Set the scale mode to scale to fit the window
        view.presentScene(scene) // Present the scene
        
        view.showsFPS = false
        view.showsNodeCount = false
    }

    override var shouldAutorotate: Bool { 
        return true 
    }
    
    override var prefersStatusBarHidden: Bool { 
        return true 
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { 
        return .landscape 
    }
}
