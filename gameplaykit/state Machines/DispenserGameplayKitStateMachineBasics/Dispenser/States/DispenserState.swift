/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    A superclass for states powering the dispenser.
*/

import SpriteKit
import GameplayKit

class DispenserState: GKState {
    // MARK: Properties
    
    /// A reference to the game scene, used to alter sprites.
    let game: GameScene
    
    /// The name of the node in the game scene that is associated with this state.
    let associatedNodeName: String
    
    /// Convenience property to get the state's associated sprite node.
    var associatedNode: SKSpriteNode? {
        return game.childNodeWithName("//\(associatedNodeName)") as? SKSpriteNode
    }
    
    // MARK: Initialization
    
    init(game: GameScene, associatedNodeName: String) {
        self.game = game
        self.associatedNodeName = associatedNodeName
    }
    
    // MARK: GKState overrides
    
    /// Highlights the sprite representing the state.
    override func didEnterWithPreviousState(previousState: GKState?) {
        guard let associatedNode = associatedNode else { return }
        associatedNode.color = SKColor.lightGrayColor()
    }
    
    /// Unhighlights the sprite representing the state.
    override func willExitWithNextState(nextState: GKState) {
        guard let associatedNode = associatedNode else { return }
        associatedNode.color = SKColor.darkGrayColor()
    }
    
    // MARK: Methods

    /// Changes the dispenser's indicator light to the specified color.
    func changeIndicatorLightToColor(color: SKColor) {
        let indicator = game.childNodeWithName("//indicator") as! SKSpriteNode
        indicator.color = color
    }
}