//
//  cameraMoveComponent.m
//  AceHunter
//
//  Created by 123 on 16/3/14.
//  Copyright © 2016年 star. All rights reserved.
//

#import "cameraMoveComponent.h"

@implementation cameraMoveComponent
-(void)updateWithDeltaTime:(NSTimeInterval)seconds
{
    if (self.hero.position.y<self.unitHeight*3 && self.hero.position.y>self.unitHeight) {
        [self.camera setPosition:CGPointMake(self.camera.position.x, self.hero.position.y)];
    }
}
@end
