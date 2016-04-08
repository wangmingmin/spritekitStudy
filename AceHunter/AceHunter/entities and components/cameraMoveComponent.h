//
//  cameraMoveComponent.h
//  AceHunter
//
//  Created by 123 on 16/3/14.
//  Copyright © 2016年 star. All rights reserved.
//

#import <GameplayKit/GameplayKit.h>
@import SpriteKit;

@interface cameraMoveComponent : GKComponent
@property (strong, nonatomic) SKSpriteNode * hero;
@property (strong, nonatomic) SKCameraNode * camera;
@property (assign, nonatomic) CGFloat unitHeight;
@end
