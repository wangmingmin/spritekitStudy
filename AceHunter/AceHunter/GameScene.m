//
//  GameScene.m
//  AceHunter
//
//  Created by 123 on 16/3/9.
//  Copyright (c) 2016年 star. All rights reserved.
//

#import "GameScene.h"
#import "cameraMoveComponent.h"
#import "agent2DComponent.h"
#import "ObstaclesArray.h"
#import "wildOx_animal.h"
#import "hawk_animal.h"

#define speedHero 70.0
#define dodgeDistance 70.0
#define canSeeYou 150.0
const static float AAPLDefaultAgentRadius = 40.0f;

//#import <simd/geometry.h>
static const uint32_t heroCategory  = 0x1 << 1;
static const uint32_t enemyCategory  = 0x1 << 2;
static const uint32_t buildingCategory = 0x1 << 3;
static const uint32_t animalCategory = 0x1 << 4;
static const uint32_t worldCategory = 0x1 << 5;

@import GameplayKit;

@interface GameScene ()<SKPhysicsContactDelegate>
@property (strong, nonatomic) SKSpriteNode * hero;
@property (strong, nonatomic) SKSpriteNode * building;

@property NSTimeInterval prevUpdateTime;
@property GKComponentSystem * enemysComponentSystem_camera;
@property GKComponentSystem * agentSystem;
@property GKComponentSystem * agentSystem_animal;

@property (strong, nonatomic) NSMutableArray * arrayEntitys;
@property (nonatomic, readwrite) agent2DComponent *trackingAgent;

@property (strong, nonatomic) GKObstacleGraph * graph;

@property (strong, nonatomic) wildOx_animal * wildOx;
@property (strong, nonatomic) hawk_animal * hawk;
@end

@implementation GameScene{
    SKCropNode *cropNode;
}

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height*2)];
    self.camera.position = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
    [self addWorldMapCircleObstacles];
    
    self.physicsBody.categoryBitMask = worldCategory;
    self.physicsBody.contactTestBitMask = animalCategory;
    
    self.hero = (SKSpriteNode *)[self childNodeWithName:@"hero"];
    self.hero.position = CGPointMake(30, 30);
    self.hero.physicsBody.categoryBitMask = heroCategory;
    self.hero.physicsBody.contactTestBitMask = buildingCategory;
//    self.hero.physicsBody.collisionBitMask = 0;
    self.trackingAgent = [[agent2DComponent alloc] init];
    self.trackingAgent.hero = self.hero;
    self.trackingAgent.radius = canSeeYou;
    self.trackingAgent.position = (vector_float2){self.hero.position.x, self.hero.position.y};
    [self.trackingAgent.behavior setWeight:100 forGoal:[GKGoal goalToAvoidObstacles:[ObstaclesArray sharedObstacles].avoidObstaclesArray maxPredictionTime:1]];

    self.agentSystem = [[GKComponentSystem alloc] initWithComponentClass:[agent2DComponent class]];
    [self.agentSystem addComponent:self.trackingAgent];
    
    self.building = (SKSpriteNode *)[self childNodeWithName:@"building"];
    self.building.physicsBody.categoryBitMask = buildingCategory;
    self.building.physicsBody.contactTestBitMask = heroCategory;
    
//    self.building.physicsBody.collisionBitMask = 0;

//    SKShader * teleportShader = [SKShader shaderWithFileNamed:@"Teleport.fsh"];
//    [teleportShader addUniform:[SKUniform uniformWithName:@"size" floatVector3:GLKVector3Make(self.building.frame.size.width, self.building.frame.size.height, 0)]];
//    self.building.shader = teleportShader;

    /*
     将categoryBitMask设置为之前定义好的monsterCategory。
     
     contactTestBitMask表示与什么类型对象碰撞时，应该通知contact代理。在这里选择炮弹类型。
     
     collisionBitMask表示物理引擎需要处理的碰撞事件。在此处我们不希望炮弹和怪物被相互弹开——所以再次将其设置为0。
     */
    
    cropNode = [[SKCropNode alloc] init];
    cropNode.zPosition = 1;
    cropNode.maskNode = self.hero;
    [self addChild:cropNode];
    
    self.physicsWorld.contactDelegate = self;

    [self setUpEntities];
    
    NSArray *obstacles =[NSArray arrayWithObject:self.building];
    NSArray *polygonObstacles = [SKNode obstaclesFromNodeBounds:obstacles];
    [ObstaclesArray sharedObstacles].sharedObstaclesArray = [[NSArray alloc]initWithArray:polygonObstacles];
    self.graph = [GKObstacleGraph graphWithObstacles:polygonObstacles bufferRadius:20.0];
    [ObstaclesArray sharedObstacles].graphShare = [[GKObstacleGraph alloc] init];
    [ObstaclesArray sharedObstacles].graphShare = self.graph;
    
    __weak typeof (self)weakSelf = self;
    self.heroDodge = ^(UISwipeGestureRecognizerDirection Direction) {//1.2.4.8 :right left up down
        NSLog(@"swipe scene... D -> %lu",(unsigned long)Direction);
        [weakSelf.hero removeAllActions];
        [weakSelf dodgeToDirection:Direction];
    };
    
    [self addAnimals];
}

-(void)addAnimals
{
    self.agentSystem_animal = [[GKComponentSystem alloc] initWithComponentClass:[GKAgent2D class]];

    self.wildOx = [[wildOx_animal alloc] initWithHeroAgent:self.trackingAgent andScene:self andCrop:cropNode];
    self.wildOx.physicsBody.categoryBitMask = animalCategory;
    self.wildOx.physicsBody.contactTestBitMask = buildingCategory;
    [self addChild:self.wildOx];
    [self.agentSystem_animal addComponent:self.wildOx.agent];
    
    self.hawk = [[hawk_animal alloc] initWithHeroAgent:self.trackingAgent andScene:self];
    self.hawk.physicsBody.categoryBitMask = animalCategory;
    self.hawk.physicsBody.contactTestBitMask = buildingCategory;
    [self addChild:self.hawk];
    [self.agentSystem_animal addComponent:self.hawk.agent];

}

-(void)addWorldMapCircleObstacles
{
    NSMutableArray * obs = [NSMutableArray array];
    int countH = (self.frame.size.height*2)/AAPLDefaultAgentRadius;
    int countW = self.frame.size.width/AAPLDefaultAgentRadius;
    for (int i = 0; i <2; i++) {
        int originX = i==0?-AAPLDefaultAgentRadius/2.0:self.frame.size.width+AAPLDefaultAgentRadius/2.0;
        for (int j = 0; j < countH; j++) {
            float originY  = AAPLDefaultAgentRadius/2.0+j*AAPLDefaultAgentRadius;
            GKObstacle * Obstacle = [self addObstacleAtPoint:CGPointMake(originX, originY) withRadius:AAPLDefaultAgentRadius];
            [obs addObject:Obstacle];
        }
    }
    
    for (int i = 0; i <2; i++) {
        int originY = i==0?-AAPLDefaultAgentRadius/2.0:self.frame.size.height*2+AAPLDefaultAgentRadius/2.0;
        for (int j = 0; j < countW; j++) {
            float originX  = AAPLDefaultAgentRadius/2.0+j*AAPLDefaultAgentRadius;
            GKObstacle * Obstacle = [self addObstacleAtPoint:CGPointMake(originX, originY) withRadius:AAPLDefaultAgentRadius];
            [obs addObject:Obstacle];
        }
    }
    
    GKObstacle * Obstacle0 = [self addObstacleAtPoint:CGPointMake(0, 0) withRadius:AAPLDefaultAgentRadius*2];
    GKObstacle * Obstacle1 = [self addObstacleAtPoint:CGPointMake(0, self.frame.size.height*2) withRadius:AAPLDefaultAgentRadius*2];
    GKObstacle * Obstacle2 = [self addObstacleAtPoint:CGPointMake(self.frame.size.width, 0) withRadius:AAPLDefaultAgentRadius*2];
    GKObstacle * Obstacle3 = [self addObstacleAtPoint:CGPointMake(self.frame.size.width, self.frame.size.height*2) withRadius:AAPLDefaultAgentRadius*2];
    [obs addObject:Obstacle0];
    [obs addObject:Obstacle1];
    [obs addObject:Obstacle2];
    [obs addObject:Obstacle3];
    [ObstaclesArray sharedObstacles].avoidObstaclesArray = obs;
}

- (GKObstacle *)addObstacleAtPoint:(CGPoint)point withRadius:(float)radius{
//    SKShapeNode *circleShape = [SKShapeNode shapeNodeWithCircleOfRadius:radius/2.0];
//    circleShape.lineWidth = 2.5;
//    circleShape.fillColor = [SKColor grayColor];
//    circleShape.strokeColor = [SKColor redColor];
//    circleShape.zPosition = 1;
//    circleShape.position = point;
//    [self addChild:circleShape];
    
    GKCircleObstacle *obstacle = [GKCircleObstacle obstacleWithRadius:radius/2.0];
    obstacle.position = (vector_float2){point.x, point.y};
    
    return obstacle;
}

-(void)didBeginContact:(SKPhysicsContact *)contact
{
    NSLog(@"碰撞测试");
    SKPhysicsBody* firstBody;
    
    SKPhysicsBody* secondBody;
    
    if (contact.bodyA.categoryBitMask == heroCategory) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }else{
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if (secondBody.categoryBitMask == enemyCategory) {
//        SKAction * action = [SKAction fadeInWithDuration:0.05];
//        [secondBody.node runAction:action];
    }
    if (firstBody.categoryBitMask == worldCategory || secondBody.categoryBitMask == worldCategory) {
        NSLog(@"撞墙...");
    }
}
-(void)didEndContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody* firstBody;
    
    SKPhysicsBody* secondBody;
    
    if (contact.bodyA.categoryBitMask == heroCategory) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }else{
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if (secondBody.categoryBitMask == enemyCategory) {
//        SKAction * action = [SKAction fadeOutWithDuration:0.2];
//        [secondBody.node runAction:action];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    GKGraphNode2D * startNode = [GKGraphNode2D nodeWithPoint:(vector_float2){self.hero.position.x,self.hero.position.y}];
    GKGraphNode2D * endNode = [GKGraphNode2D nodeWithPoint:(vector_float2){location.x,location.y}];
    [self.graph connectNodeUsingObstacles:startNode];
    [self.graph connectNodeUsingObstacles:endNode];
    NSArray * path = [self.graph findPathFromNode:startNode toNode:endNode];
    if (path.count <1) {
        return;
    }
    [self.hero removeAllActions];
    moveForPathNode(path,self.hero);
    GKPath * pathGk = [GKPath pathWithGraphNodes:path radius:45.0f];
    [self.graph removeNodes:@[startNode,endNode]];
}

-(void)setUpEntities {
    GKEntity * cameraBox = [[GKEntity alloc] init];

    cameraMoveComponent * cameraComponent = [[cameraMoveComponent alloc] init];
    cameraComponent.camera = self.camera;
    cameraComponent.hero = self.hero;
    cameraComponent.unitHeight = self.frame.size.height/2.0;
    [cameraBox addComponent:cameraComponent];
    
    self.enemysComponentSystem_camera = [[GKComponentSystem alloc] initWithComponentClass:[cameraMoveComponent class]];
    [self.enemysComponentSystem_camera addComponentWithEntity:cameraBox];

    self.arrayEntitys = [NSMutableArray array];
    [self.arrayEntitys addObject:cameraBox];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
#pragma wildOx
    float distance = vector_distance(self.trackingAgent.position, self.wildOx.agent.position);
    const static float maxDistance = 100.0;
    BOOL isseek = NO;
    if (distance<maxDistance) {
        isseek = YES;
    }else{
        isseek = NO;
    }
    self.wildOx.isSeek = isseek;
//    NSLog(@"bool isseek = %d  distance = %f",isseek,distance);
    
    if (self.prevUpdateTime == 0) {
        self.prevUpdateTime = currentTime;
    }
    float dt = currentTime - self.prevUpdateTime;
    self.prevUpdateTime = currentTime;
    [self.enemysComponentSystem_camera updateWithDeltaTime:dt];
    [self.agentSystem updateWithDeltaTime:dt];
    [self.agentSystem_animal updateWithDeltaTime:dt];
}


void rotateSprite(SKSpriteNode * Sprite,CGPoint direction) {//旋转
    Sprite.zRotation = atan2(direction.y-Sprite.position.y, direction.x-Sprite.position.x);
//    NSLog(@"sprite.zrotation = %f",Sprite.zRotation);
    /*  zrotation: atan2
             1.5
              |
              |
     ±3. -----O----- ±0
              |
              |
            -1.5
     */
}

void moveForPathNode(NSArray *pathPoints,SKNode * hero) {
    NSInteger count = pathPoints.count;
    NSMutableArray * points = [NSMutableArray arrayWithCapacity:count];
    for (int i = 1; i<count; i++) {//pathPoints[0]就是hero的当前位置,应排除在外
        GKGraphNode2D *po = pathPoints[i];
        GKGraphNode2D *poBefore = pathPoints[i-1];
        CGPoint point = CGPointMake(po.position.x, po.position.y);
        CGFloat xDist = (point.x - poBefore.position.x);
        CGFloat yDist = (point.y - poBefore.position.y);
        double distance = sqrt((xDist * xDist) + (yDist * yDist));
        SKAction * move = [SKAction moveTo:point duration:distance/speedHero];
        SKAction * rotation = [SKAction runBlock:^{
            rotateSprite((SKSpriteNode *)hero, point);
        }];
        SKAction * sequenceAction = [SKAction sequence:@[rotation,move]];
        [points addObject:sequenceAction];
    }
    [hero runAction:[SKAction sequence:points]];
    
}

-(void) dodgeToDirection:(UISwipeGestureRecognizerDirection) Direction{
    SKAction * move;
    switch (Direction) {
        case UISwipeGestureRecognizerDirectionRight:
            move = [SKAction moveTo:CGPointMake(MIN(self.hero.position.x+dodgeDistance, self.frame.size.width-self.hero.frame.size.width/2.0), self.hero.position.y) duration:0.1];
            break;
        case UISwipeGestureRecognizerDirectionLeft:
            move = [SKAction moveTo:CGPointMake(MAX(self.hero.position.x-dodgeDistance, self.hero.frame.size.width/2.0), self.hero.position.y) duration:0.1];
            break;
        case UISwipeGestureRecognizerDirectionUp:
            move = [SKAction moveTo:CGPointMake(self.hero.position.x, MIN(self.hero.position.y+dodgeDistance, self.frame.size.height*2-self.hero.frame.size.height/2.0)) duration:0.1];
            break;
        case UISwipeGestureRecognizerDirectionDown:
            move = [SKAction moveTo:CGPointMake(self.hero.position.x, MAX(self.hero.position.y-dodgeDistance, self.hero.frame.size.height/2.0)) duration:0.1];
            break;

        default:
            break;
    }
    
    [self.hero runAction:move];
}
@end
