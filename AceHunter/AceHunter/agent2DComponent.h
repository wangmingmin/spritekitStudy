//
//  agent2DComponent.h
//  AceHunter
//
//  Created by 123 on 16/3/23.
//  Copyright © 2016年 star. All rights reserved.
//

#import <GameplayKit/GameplayKit.h>
@import SpriteKit;

@interface agent2DComponent : GKAgent2D
@property (strong, nonatomic) SKSpriteNode * hero;
@end
