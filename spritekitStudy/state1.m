//
//  state1.m
//  spritekitStudy
//
//  Created by 123 on 16/3/3.
//  Copyright © 2016年 star. All rights reserved.
//

#import "state1.h"

@implementation state1
-(BOOL)isValidNextState:(Class)stateClass
{
    //第一步 返回no，则不改变状态
    return YES;
}

-(void)didEnterWithPreviousState:(GKState *)previousState
{
    
}

-(void)willExitWithNextState:(GKState *)nextState
{
    
}

-(void)updateWithDeltaTime:(NSTimeInterval)seconds
{
    
}
@end
