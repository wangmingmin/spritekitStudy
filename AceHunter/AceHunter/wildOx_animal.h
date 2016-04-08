//
//  wildOx_animal.h
//  AceHunter
//
//  Created by 123 on 16/3/23.
//  Copyright © 2016年 star. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@import GameplayKit;
@interface wildOx_animal : SKSpriteNode
-(instancetype)initWithHeroAgent:(GKAgent2D *)heroAgent andScene:(SKScene *)scene andCrop:(SKCropNode *)cropNode;
@property (strong, nonatomic) GKAgent2D * agent;
@property (assign, nonatomic) BOOL isSeek;
@property (strong, nonatomic) GKStateMachine * stateMachine;
@property (strong, nonatomic) SKSpriteNode * cropNode;
@end
