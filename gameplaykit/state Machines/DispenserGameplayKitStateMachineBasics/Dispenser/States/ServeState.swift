/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    A state for use in a dispenser's state machine. This state dispenses water from the dispenser. It plays a brief dispensing animation before exiting.
*/

import SpriteKit
import GameplayKit

class ServeState: DispenserState {
    // MARK: Properties
    
    /// A multiplier for the speed of the dispensing animation.
    static let timeScale = 0.5
    
    // MARK: Initialization
    
    required init(game: GameScene) {
        super.init(game: game, associatedNodeName: "ServeState")
    }
    
    // MARK: GKState overrides
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        super.didEnterWithPreviousState(previousState)
        
        playDispensingAnimationThenExit()
    }
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        /*
            This state can only transition to the partially full and empty 
            states.
        */
        switch stateClass {
            case is PartiallyFullState.Type, is EmptyState.Type:
                return true
            
            default:
                return false
        }
    }
    
    // MARK: Other Game Logic
    
    /**
        Creates and plays the dispensing animation, then tells the state
        machine to enter the empty or partially full state, depending on the
        resultant water level.
    */
    func playDispensingAnimationThenExit() {
        // These nodes create base actions to be run on nodes in the scene.
        let slideCupAction    = SKAction(named: "slideCup", duration: 3 * ServeState.timeScale)!
        let fillCupAction     = SKAction(named: "fillCup", duration: 2 * ServeState.timeScale)!
        let resetStreamAction = SKAction(named: "resetStream", duration: 0)!
        let resetCupAction    = SKAction(named: "resetCup", duration: 0)!
        let drainWaterAction  = SKAction(named: "drainWater", duration: ServeState.timeScale)!
        
        // These nodes run an action on a node.
        let slideCupActionOnNode    = SKAction.runAction(slideCupAction, onChildWithName: "//bottle")
        let fillCupActionOnNode     = SKAction.runAction(fillCupAction, onChildWithName: "//stream")
        let resetStreamActionOnNode = SKAction.runAction(resetStreamAction, onChildWithName: "//stream")
        let resetCupActionOnNode    = SKAction.runAction(resetCupAction, onChildWithName: "//bottle")
        let drainWaterActionOnNode  = SKAction.runAction(drainWaterAction, onChildWithName: "//water")
        
        // This action inserts a delay into a sequence.
        let waitAction = SKAction.waitForDuration(ServeState.timeScale)
        
        // This action defines a timed sequence of events.
        let innerSequence = [
            waitAction,
            drainWaterActionOnNode,
            waitAction,
            resetStreamActionOnNode,
            waitAction,
            resetCupActionOnNode
        ]
        let innerSequenceAction = SKAction.sequence(innerSequence)
        
        // This action defines a group of actions to play simultaneously. 
        let group = [slideCupActionOnNode, fillCupActionOnNode, innerSequenceAction]
        let groupAction = SKAction.group(group)
        
        // Play the dispensing animation, then exit conditionally. 
        game.scene?.runAction(groupAction) {
            let waterNode = self.game.childNodeWithName("//water") as! SKSpriteNode
            if waterNode.size.height < 1 {
                self.stateMachine?.enterState(EmptyState)
            }
            else {
                self.stateMachine?.enterState(PartiallyFullState)
            }
        }
    }
}