//
//  colorComponent.m
//  spritekitStudy
//
//  Created by 123 on 16/3/2.
//  Copyright © 2016年 star. All rights reserved.
//

#import "colorComponent.h"

@implementation colorComponent
-(void)updateWithDeltaTime:(NSTimeInterval)seconds
{
    self.color = [UIColor blackColor];
    self.spriteNode.color = self.color;
}

-(void)changeColor
{
    self.color = [UIColor redColor];
    self.spriteNode.color = self.color;
}
@end
