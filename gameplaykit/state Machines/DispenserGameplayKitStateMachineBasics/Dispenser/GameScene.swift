/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Handles logic, updates, and input for the scene. Primarily, it creates and manages the game's state machine.
*/

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    // MARK: Properties

    /**
        Controls the states of the dispenser. This property is an implicitly 
        unwrapped optional because it will not be modified after it is 
        configured in `didMoveToView(_:)`.
    */
    var stateMachine: GKStateMachine!
    
    /// Keeps track of the time for use in the update method.
    var previousUpdateTime: NSTimeInterval = 0

    // MARK: SKScene overrides
    
    override func didMoveToView(_: SKView) {
        // Creates and adds states to the dispenser's state machine.
        stateMachine = GKStateMachine(states: [
            FullState(game: self),
            PartiallyFullState(game: self),
            EmptyState(game: self),
            RefillingState(game: self),
            ServeState(game: self)
        ])
        
        // Tells the state machine to enter the full state.
        stateMachine.enterState(FullState.self)
    }
    
    override func didChangeSize(oldSize: CGSize) {
        let dispenser = childNodeWithName("dispenser")!
        dispenser.position.x = size.width / 2
    }
    
    override func update(currentTime: NSTimeInterval) {
        // Calculate the time change since the previous update.
        let timeSincePreviousUpdate = currentTime - previousUpdateTime
        
        // The Empty state uses this to keep the indicator light flashing.
        stateMachine.updateWithDeltaTime(timeSincePreviousUpdate)
        
        /*
            Set previousUpdateTime to the current time, so the next update has
            accurate information.
        */
        previousUpdateTime = currentTime
    }
    
    // MARK: Game Logic

    /**
        Tells the state machine to enter the serve state. It will fail if the
        transition is not valid.
    */
    func attemptToDispense() {
        stateMachine.enterState(ServeState.self)
    }
    
    /**
        Tells the state machine to enter the refilling state. It will fail if 
        the transition is not valid.
    */
    func attemptToRefill() {
        // Grab the refill button from the scene.
        let refillButton = childNodeWithName("//refillButton")!
        
        /*
            Create and run an animation on the refill button to show that the 
            button has been pressed.
        */
        let buttonPressedAction = SKAction(named: "buttonPressed", duration: 0.6)!
        refillButton.runAction(buttonPressedAction)
        
        // Attempt to enter the Refill state. 
        stateMachine.enterState(RefillingState.self)
    }
    
    /**
        Decides whether to attempt to dispense or to refill the dispenser, 
        given a touch location or click location. If the refill button was 
        touched/clicked, attempt to refill. Otherwise, attempt to dispense.
    */
    func dispenseOrRefill(location: CGPoint) {
        // Grab the refill button from the scene.
        let refillButton = childNodeWithName("//refillButton")!
        
        /*
            If the refill button was touched/clicked, attempt to refill the 
            dispenser. Otherwise, attempt to dispense water.
        */
        if nodeAtPoint(location) === refillButton {
            attemptToRefill()
        }
        else {
            attemptToDispense()
        }
    }
    
    // MARK: Input Handling (OS X)
    #if os(OSX)
    
    override func keyDown(_: NSEvent) {
        // Press any key to dispense.
        attemptToDispense()
    }
    
    override func mouseDown(event: NSEvent) {
        // Click the refill button to refill, or anywhere else to dispense.
        let clickLocation = event.locationInNode(self)
        dispenseOrRefill(clickLocation)
    }
    
    // MARK: Input Handling (iOS)
    #elseif os(iOS)
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Tap the refill button to refill, or anywhere else to dispense.
        let touchLocationInView = touches.first!.locationInView(view)
        let touchLocationInScene = convertPointFromView(touchLocationInView)
        dispenseOrRefill(touchLocationInScene)
    }
    
    // MARK: Input Handling (tvOS)
    #elseif os(tvOS)
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Tap the Siri Remote touch surface to dispense.
        attemptToDispense()
    }
    override func pressesEnded(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        // Click the Siri Remote touch surface to refill.
        attemptToRefill()
    }
    
    #endif
}
