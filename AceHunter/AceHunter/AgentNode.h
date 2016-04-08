//
//  AgentNode.h
//  AceHunter
//
//  Created by 123 on 16/3/16.
//  Copyright © 2016年 star. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@import GameplayKit;

@interface AgentNode : SKSpriteNode <GKAgentDelegate>
- (instancetype)initWithScene:(SKScene *)scene radius:(float)radius position:(CGPoint)position;

@property (readonly) GKAgent2D *agent;

@end
