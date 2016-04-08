/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    A state for use in a dispenser's state machine. This state represents when the dispenser is full. It turns on the dispenser's indicator light.
*/

import SpriteKit
import GameplayKit

class FullState: DispenserState {
    
    // MARK: Initialization
    
    required init(game: GameScene) {
        super.init(game: game, associatedNodeName: "FullState")
    }
    
    // MARK: GKState overrides
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        super.didEnterWithPreviousState(previousState)
        
        // Turn on the indicator light with a green color.
        let greenColor = SKColor.greenColor()
        changeIndicatorLightToColor(greenColor)
    }
    
    override func willExitWithNextState(nextState: GKState) {
        super.willExitWithNextState(nextState)

        // Turn off the indicator light.
        let blackColor = SKColor.blackColor()
        changeIndicatorLightToColor(blackColor)
    }
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        // This state can only transition to the serve state. 
        return stateClass is ServeState.Type
    }
}