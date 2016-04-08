/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    A state for use in a dispenser's state machine. This state represents when the dispenser is empty. It flashes the dispenser's warning light.
*/

import SpriteKit
import GameplayKit

class EmptyState: DispenserState {
    // MARK: Properties
    
    /// Keeps track of time between indicator light toggles.
    var flashTimeCounter: NSTimeInterval = 0
    
    /// Defines the time interval between when the light is toggled.
    static let flashInterval = 0.6
    
    /// Changes the color of the indicator light to red or black when toggled.
    var lightOn = true {
        didSet {
            if lightOn {
                let redColor = SKColor.redColor()
                changeIndicatorLightToColor(redColor)
            }
            else {
                let blackColor = SKColor.blackColor()
                changeIndicatorLightToColor(blackColor)
            }
        }
    }
    
    // MARK: Initialization
    
    required init(game: GameScene) {
        super.init(game: game, associatedNodeName: "EmptyState")
    }
    
    // MARK: GKState overrides
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        super.didEnterWithPreviousState(previousState)
        
        // Turn on the indicator light with a red color.
        let red = SKColor.redColor()
        changeIndicatorLightToColor(red)
    }
    
    override func willExitWithNextState(nextState: GKState) {
        super.willExitWithNextState(nextState)
        
        // Turn on the indicator light with a green color.
        let black = SKColor.blackColor()
        changeIndicatorLightToColor(black)
    }
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        // This state can only transition to the refilling state. 
        return stateClass is RefillingState.Type
    }
    
    override func updateWithDeltaTime(deltaTime: NSTimeInterval) {
        // Keep track of the time since the last update.
        flashTimeCounter += deltaTime
        
        /*
            If an interval of `flashInterval` has passed since the previous update,
            toggle the indicator light and reset the time counter.
        */
        if flashTimeCounter > EmptyState.flashInterval {
            lightOn = !lightOn
            flashTimeCounter = 0
        }
    }
}