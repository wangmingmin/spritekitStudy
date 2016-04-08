//
//  agent2DComponent.m
//  AceHunter
//
//  Created by 123 on 16/3/23.
//  Copyright © 2016年 star. All rights reserved.
//

#import "agent2DComponent.h"

@implementation agent2DComponent
-(instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void)updateWithDeltaTime:(NSTimeInterval)seconds
{
    self.position = (vector_float2){self.hero.position.x, self.hero.position.y};
//    NSLog(@"x = %f   y = %f",self.position.x,self.position.y);
}
@end
