//
//  hawk_animal.h
//  AceHunter
//
//  Created by 123 on 16/3/26.
//  Copyright © 2016年 star. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@import GameplayKit;

@interface hawk_animal : SKSpriteNode
-(instancetype)initWithHeroAgent:(GKAgent2D *)heroAgent andScene:(SKScene *)scene;
@property (strong, nonatomic) GKAgent2D * agent;
@property (strong, nonatomic) GKStateMachine * stateMachine;
@end
