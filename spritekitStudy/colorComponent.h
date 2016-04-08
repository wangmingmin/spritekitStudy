//
//  colorComponent.h
//  spritekitStudy
//
//  Created by 123 on 16/3/2.
//  Copyright © 2016年 star. All rights reserved.
//

#import <GameplayKit/GameplayKit.h>
@import SpriteKit;
@interface colorComponent : GKComponent
@property (strong, nonatomic) SKSpriteNode * spriteNode;
@property (strong, nonatomic) UIColor * color;
-(void) changeColor;
@end
