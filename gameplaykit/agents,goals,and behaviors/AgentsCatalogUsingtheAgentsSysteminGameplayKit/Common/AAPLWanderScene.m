/*
	Copyright (C) 2015 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	Non-interactive demonstration of wander behavior.
 */

#import "AAPLWanderScene.h"
#import "AAPLAgentNode.h"

@implementation AAPLWanderScene

- (NSString *)sceneName {
    return @"WANDERING";
}

- (void)didMoveToView:(nonnull SKView *)view {
    [super didMoveToView:view];
	
	// The wanderer agent simply moves aimlessly through the scene.
    AAPLAgentNode *wanderer = [[AAPLAgentNode alloc] initWithScene:self
                                                          radius:AAPLDefaultAgentRadius
                                                        position:CGPointMake(CGRectGetMidX(self.frame),
                                                                             CGRectGetMidY(self.frame))];
	wanderer.color = [SKColor cyanColor];
    wanderer.agent.behavior = [GKBehavior behaviorWithGoal:[GKGoal goalToWander:10] weight:100];
    [self.agentSystem addComponent:wanderer.agent];
    NSArray<GKObstacle *> *obstacles = @[

                                         [self addObstacleAtPoint:CGPointMake(CGRectGetMidX(self.frame),
                                                                              CGRectGetMidY(self.frame) + 150)],
                                         [self addObstacleAtPoint:CGPointMake(CGRectGetMidX(self.frame) - 200,
                                                                              CGRectGetMidY(self.frame) - 150)],
                                         [self addObstacleAtPoint:CGPointMake(CGRectGetMidX(self.frame) + 200,
                                                                              CGRectGetMidY(self.frame) - 150)]
                                         ];
    
    [wanderer.agent.behavior setWeight:100 forGoal:[GKGoal goalToAvoidObstacles:obstacles maxPredictionTime:1]];
}


- (GKObstacle *)addObstacleAtPoint:(CGPoint)point {
    SKSpriteNode *circleShape = [SKSpriteNode spriteNodeWithColor:[SKColor blueColor] size:CGSizeMake(90, 90)];
    circleShape.zPosition = 1;
    circleShape.position = point;
    circleShape.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:circleShape.size];
    circleShape.physicsBody.dynamic = NO;
    circleShape.physicsBody.affectedByGravity = NO;
    [self addChild:circleShape];
    
    GKCircleObstacle *obstacle = [GKCircleObstacle obstacleWithRadius:circleShape.size.height/2.0];
    obstacle.position = (vector_float2){point.x, point.y};
    
    return obstacle;
}

@end
