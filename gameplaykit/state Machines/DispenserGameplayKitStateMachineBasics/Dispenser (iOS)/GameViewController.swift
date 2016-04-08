/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    A `UIViewController` subclass that stores references to game-wide input sources and managers.
*/

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    // MARK: Properties
    
    let scene = GameScene(fileNamed: "GameScene")!
    
    // MARK: Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let skView = view as! SKView
        
        // Resize the scene to better use the device aspect ratio.
        let scaleFactor = scene.size.height / view.bounds.height
        // This app runs only in landscape, so height always determines scale.
        scene.scaleMode = .AspectFit
        scene.size.width = view.bounds.width * scaleFactor
            
        skView.presentScene(scene)
        
        // SpriteKit applies additional optimizations to improve rendering performance.
        skView.ignoresSiblingOrder = true
    }
        
    #if os(tvOS)
    /// SpriteKit doesn't automatically forward press events, so do that manually.
    override func pressesEnded(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        scene.pressesEnded(presses, withEvent: event)
    }
    #endif
}