//
//  AgentNode.m
//  AceHunter
//
//  Created by 123 on 16/3/16.
//  Copyright © 2016年 star. All rights reserved.
//

#import "AgentNode.h"

@implementation AgentNode
- (instancetype)initWithScene:(SKScene *)scene radius:(float)radius position:(CGPoint)position {
    self = [super init];
    
    if (self) {
        self.size = CGSizeMake(30, 30);
        self.position = position;
        self.zPosition = 0;
        [scene addChild:self];
        
        // An agent to manage the movement of this node in a scene.
        _agent = [[GKAgent2D alloc] init];
        _agent.radius = radius;
        _agent.position = (vector_float2){position.x, position.y};
        _agent.delegate = self;
        _agent.maxSpeed = 100;
        _agent.maxAcceleration = 50;

        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
        self.physicsBody.dynamic = YES;
        self.physicsBody.affectedByGravity = NO;
    }
    
    return self;
}

#pragma mark - GKAgentDelegate

- (void)agentWillUpdate:(nonnull GKAgent2D *)agent {
    // All changes to agents in this app are driven by the agent system, so
    // there's no other changes to pass into the agent system in this method.

//    agent.position = (vector_float2){self.position.x, self.position.y};
//    agent.rotation = self.zRotation;
}

- (void)agentDidUpdate:(nonnull GKAgent2D *)agent {
    // Agent and sprite use the same coordinate system (in this app),
    // so just convert vector_float2 position to CGPoint.
    self.position = CGPointMake(agent.position.x, agent.position.y);
//    NSLog(@"xxx = %f   yyyy = %f",agent.position.x, agent.position.y);
    self.zRotation = agent.rotation;
}
@end
