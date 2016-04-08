//
//  ObstaclesArray.h
//  AceHunter
//
//  Created by 123 on 16/3/23.
//  Copyright © 2016年 star. All rights reserved.
//

#import <Foundation/Foundation.h>
@import GameplayKit;

@interface ObstaclesArray : NSArray
+ (instancetype)sharedObstacles;
@property (strong, nonatomic) NSArray * sharedObstaclesArray;//biulding
@property (strong, nonatomic) GKObstacleGraph * graphShare;
@property (strong, nonatomic) NSArray * avoidObstaclesArray;
@end
