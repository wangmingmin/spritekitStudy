//
//  ObstaclesArray.m
//  AceHunter
//
//  Created by 123 on 16/3/23.
//  Copyright © 2016年 star. All rights reserved.
//

#import "ObstaclesArray.h"

@implementation ObstaclesArray
+(instancetype)sharedObstacles
{
    static ObstaclesArray * _sharedObstacles = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedObstacles = [[ObstaclesArray alloc]init];
    });
    return _sharedObstacles;
}
@end
