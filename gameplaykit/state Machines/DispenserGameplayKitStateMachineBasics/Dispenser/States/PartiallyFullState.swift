/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    A state for use in a dispenser's state machine. This state represents when the dispenser is partially full.
*/

import SpriteKit
import GameplayKit

class PartiallyFullState: DispenserState {
    
    // MARK: Initialization
    
    required init(game: GameScene) {
        super.init(game: game, associatedNodeName: "PartiallyFullState")
    }
    
    // MARK: GKState overrides
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        // This state can only transition to the serve and refilling states. 
        switch stateClass {
            case is ServeState.Type, is RefillingState.Type:
                return true
            
            default:
                return false
        }
    }
}