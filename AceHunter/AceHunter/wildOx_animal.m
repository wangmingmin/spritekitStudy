//
//  wildOx_animal.m
//  AceHunter
//
//  Created by 123 on 16/3/23.
//  Copyright © 2016年 star. All rights reserved.
//

#import "wildOx_animal.h"
#import "ObstaclesArray.h"
#import "state1.h"
#import "state2.h"

@interface wildOx_animal ()<GKAgentDelegate>
@property (strong, nonatomic) NSArray * polygonObstacles;
@property (strong, nonatomic) GKAgent2D * heroAgent;
@property (strong, nonatomic) GKPath * pathRun;
@property SKEmitterNode *particles;
@property CGFloat defaultParticleRate;
@property (nonatomic) BOOL drawsTrail;
@end

@implementation wildOx_animal
-(instancetype)initWithHeroAgent:(GKAgent2D *)heroAgent andScene:(SKScene *)scene andCrop:(SKCropNode *)cropNode
{
    self = [super init];
    if (self) {
        self.size = CGSizeMake(25, 25);
        self.position = CGPointMake(50, 350);
        self.color = [UIColor orangeColor];
        self.cropNode = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:173.0/255.0 green:173.0/255.0 blue:173.0/255.0 alpha:1] size:self.size];
        self.cropNode.position = self.position;
        [cropNode addChild:self.cropNode];
        
        self.agent = [[GKAgent2D alloc] init];
        self.agent.radius = 20;
        self.agent.position = (vector_float2){self.position.x, self.position.y};
        self.agent.rotation = self.zRotation;
        self.agent.delegate =self;
        self.agent.maxSpeed = 50;
        self.agent.maxAcceleration = 50;
        self.agent.behavior  = [[GKBehavior alloc] init];
        self.heroAgent = [[GKAgent2D alloc] init];
        self.heroAgent = heroAgent;
        
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
        self.physicsBody.dynamic = YES;
        self.physicsBody.affectedByGravity = NO;
        
//        self.polygonObstacles = [[NSArray alloc] initWithArray:[ObstaclesArray sharedObstacles].sharedObstaclesArray];
//        NSArray * arrayAvoid = [ObstaclesArray sharedObstacles].avoidObstaclesArray;
        
//        [self.agent.behavior setWeight:100 forGoal:[GKGoal goalToWander:10]];
//        [self.agent.behavior setWeight:10 forGoal:[GKGoal goalToAvoidObstacles:arrayAvoid maxPredictionTime:1]];

        vector_float2 center = { CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) };
        vector_float2 points[10] = {
            { center.x, center.y + 50 },
            { center.x + 50, center.y + 150 },
            { center.x + 100, center.y + 150 },
            { center.x + 200, center.y + 200 },
            { center.x + 350, center.y + 150 },
            { center.x + 300, center.y },
            { center.x, center.y - 200 },
            { center.x + 200, center.y + 100 },
            { center.x + 200, center.y },
            { center.x + 100, center.y + 50 }
        };
        // Create a behavior that makes the agent follow along the path.
        self.pathRun = [GKPath pathWithPoints:points count:10 radius:10 cyclical:YES];
        
        [self.agent.behavior setWeight:1 forGoal:[GKGoal goalToFollowPath:self.pathRun maxPredictionTime:1.5 forward:YES]];

/*
        GKGraphNode2D * startNode = [GKGraphNode2D nodeWithPoint:(vector_float2){self.position.x+1,self.position.y+1}];
        GKGraphNode2D * endNode = [GKGraphNode2D nodeWithPoint:(vector_float2){scene.frame.size.width-self.size.width/2.0,300}];
        [[ObstaclesArray sharedObstacles].graphShare connectNodeUsingObstacles:startNode];
        [[ObstaclesArray sharedObstacles].graphShare connectNodeUsingObstacles:endNode];
        NSArray * path = [[ObstaclesArray sharedObstacles].graphShare findPathFromNode:startNode toNode:endNode];
        if (path.count>1) {
            NSMutableArray * arrayP = [[NSMutableArray alloc]initWithCapacity:path.count*2-1];
            [arrayP addObjectsFromArray:path];
//            [arrayP addObject:path.firstObject];
            for (int i = 0;i<path.count-1;i++) {//重复走动最好是闭环
                [arrayP addObject:path[path.count-2-i]];
            }
            self.pathRun = [GKPath pathWithGraphNodes:arrayP radius:20];
            self.pathRun.cyclical = YES;
 
            [self.agent.behavior setWeight:1 forGoal:[GKGoal goalToFollowPath:self.pathRun maxPredictionTime:1.5 forward:YES]];
            [[ObstaclesArray sharedObstacles].graphShare removeNodes:@[startNode,endNode]];
            
            CGPoint cgPoints[path.count];
            for (NSInteger i = 0; i < path.count; i++){
                GKGraphNode2D * Node = path[i];
                cgPoints[i] = CGPointMake(Node.position.x, Node.position.y);
            }
            cgPoints[path.count] = cgPoints[0]; // Repeat the last point to create a closed path.
            SKShapeNode* pathShape = [SKShapeNode shapeNodeWithPoints:cgPoints count:path.count];
            pathShape.lineWidth = 2;
            pathShape.strokeColor = [SKColor magentaColor];
            [scene addChild:pathShape];
        }
 */
    }
    
//    _particles = [SKEmitterNode nodeWithFileNamed:@"smoke.sks"];
//    _defaultParticleRate = _particles.particleBirthRate;
//    _particles.position = CGPointMake(-self.size.width/2.0 + 5, 0);
//    _particles.targetNode = scene;
//    _particles.zPosition = 0;
//    [self addChild:_particles];

    return self;
}

- (void)setDrawsTrail:(BOOL)drawsTrail {
    _drawsTrail = drawsTrail;
    if (_drawsTrail) {
        self.particles.particleBirthRate = self.defaultParticleRate;
    }
    else {
        self.particles.particleBirthRate = 0;
    }
}

static bool contrastSeek = NO;
-(void)setIsSeek:(BOOL)isSeek
{
    if (contrastSeek != isSeek) {
        [self.agent.behavior removeAllGoals];
        contrastSeek = isSeek;
        NSLog(@"bool isseek = %d ",contrastSeek);
        if (contrastSeek) {
            [self.agent.behavior setWeight:1 forGoal:[GKGoal goalToSeekAgent:self.heroAgent]];
//            [self.agent.behavior setWeight:0 forGoal:[GKGoal goalToReachTargetSpeed:0]];
            self.drawsTrail = NO;
        }else{
//            [self.agent.behavior setWeight:1 forGoal:[GKGoal goalToReachTargetSpeed:0]];
            [self.agent.behavior setWeight:1 forGoal:[GKGoal goalToFollowPath:self.pathRun maxPredictionTime:1.0 forward:YES]];
            self.drawsTrail = YES;
        }
    }
}

-(void)setUpState
{
    state1 * stateOne = [state1 state];
    state2 * stateTwo = [state2 state];
    
    self.stateMachine = [GKStateMachine stateMachineWithStates:@[stateOne,stateTwo]];
    [self.stateMachine enterState:state1.class];
    [self.stateMachine updateWithDeltaTime:1];
}

#pragma mark - GKAgentDelegate

- (void)agentWillUpdate:(nonnull GKAgent2D *)agent {
    // All changes to agents in this app are driven by the agent system, so
    // there's no other changes to pass into the agent system in this method.
    
    //    agent.position = (vector_float2){self.position.x, self.position.y};
    //    agent.rotation = self.zRotation;
}

- (void)agentDidUpdate:(nonnull GKAgent2D *)agent {
    // Agent and sprite use the same coordinate system (in this app),
    // so just convert vector_float2 position to CGPoint.
    self.position = self.cropNode.position=CGPointMake(agent.position.x, agent.position.y);
    //    NSLog(@"xxx = %f   yyyy = %f",agent.position.x, agent.position.y);
    self.zRotation = self.cropNode.zRotation=agent.rotation;
}

@end
