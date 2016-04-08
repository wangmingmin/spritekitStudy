//
//  GameScene.h
//  AceHunter
//

//  Copyright (c) 2016年 star. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
typedef void (^dodgeAction) (UISwipeGestureRecognizerDirection Direction);

@interface GameScene : SKScene
@property (copy, nonatomic) dodgeAction heroDodge;
@end
