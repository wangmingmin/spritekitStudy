//
//  hawk_animal.m
//  AceHunter
//
//  Created by 123 on 16/3/26.
//  Copyright © 2016年 star. All rights reserved.
//

#import "hawk_animal.h"
#import "ObstaclesArray.h"
#import "state1.h"
#import "state2.h"

@interface hawk_animal ()<GKAgentDelegate>
@property (strong, nonatomic) NSArray * polygonObstacles;
@property (strong, nonatomic) GKAgent2D * heroAgent;
@property (strong, nonatomic) GKPath * pathRun;
@property SKEmitterNode *particles;
@property CGFloat defaultParticleRate;
@property (nonatomic) BOOL drawsTrail;
@property (strong, nonatomic) GKAgent2D * seekForWander;
@end

@implementation hawk_animal
-(instancetype)initWithHeroAgent:(GKAgent2D *)heroAgent andScene:(SKScene *)scene
{
    self = [super init];
    if (self) {
        self.size = CGSizeMake(25, 25);
        self.position = CGPointMake(450, 350);
        self.zPosition = 5;
        self.color = [UIColor orangeColor];
        
        self.agent = [[GKAgent2D alloc] init];
        self.agent.radius = 20;
        self.agent.position = (vector_float2){self.position.x, self.position.y};
        self.agent.rotation = self.zRotation;
        self.agent.delegate =self;
        self.agent.maxSpeed = 100;
        self.agent.maxAcceleration = 50;
        self.agent.behavior  = [[GKBehavior alloc] init];
        self.heroAgent = [[GKAgent2D alloc] init];
        self.heroAgent = heroAgent;
        
        self.seekForWander = [[GKAgent2D alloc] init];
        self.seekForWander.position = self.heroAgent.position;
        
        [self.agent.behavior setWeight:100 forGoal:[GKGoal goalToSeekAgent:self.seekForWander]];
        
        [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(change) userInfo:nil repeats:YES];

    }
    
    _particles = [SKEmitterNode nodeWithFileNamed:@"smoke.sks"];
    _defaultParticleRate = _particles.particleBirthRate;
    _particles.position = CGPointMake(-self.size.width/2.0 + 5, 0);
    _particles.targetNode = scene;
    _particles.zPosition = 0;
    [self addChild:_particles];
    
    return self;
}

-(void)change
{
    //可在此处为老鹰改变动画
    self.drawsTrail = self.particles.particleBirthRate==0;
    
    NSArray * deck = @[@-100,@0, @100, @200, @300, @400,@500,@600,@700];
    deck = [[GKRandomSource sharedRandom] arrayByShufflingObjectsInArray:deck];
    self.seekForWander.position = (vector_float2){[deck.firstObject floatValue], [deck.lastObject floatValue]};
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
    agent.position = (vector_float2){self.position.x, self.position.y};
    agent.rotation = self.zRotation;
}

- (void)agentDidUpdate:(nonnull GKAgent2D *)agent {
    // Agent and sprite use the same coordinate system (in this app),
    // so just convert vector_float2 position to CGPoint.
    self.position = CGPointMake(agent.position.x, agent.position.y);
    //    NSLog(@"xxx = %f   yyyy = %f",agent.position.x, agent.position.y);
    self.zRotation = agent.rotation;
}

@end
