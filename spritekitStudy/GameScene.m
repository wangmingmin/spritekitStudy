//
//  GameScene.m
//  spritekitStudy
//
//  Created by 123 on 16/2/25.
//  Copyright (c) 2016年 star. All rights reserved.
//

#import "GameScene.h"
#import "HelloScene.h"
#import "colorComponent.h"
#import "sizeComponent.h"
#import "state1.h"
#import "state2.h"
#define speedHero 100.0

static const uint32_t heroCategory  = 0x1 << 0;

// 00000000000000000000000000000001

static const uint32_t enemyCategory = 0x1 << 1;

// 00000000000000000000000000000010

static const uint32_t animalCategory = 0x1 << 2;

// 00000000000000000000000000000100

static const uint32_t buildingCategory = 0x1 << 3;

// 00000000000000000000000000001000


@import GameplayKit;

@interface GameScene ()<SKPhysicsContactDelegate>
@property NSTimeInterval prevUpdateTime;

@property (strong, nonatomic) GKObstacleGraph * graph;
@property GKComponentSystem * enemysComponentSystem;
@property (strong, nonatomic) NSMutableArray * arrayEntitys;
@property (strong, nonatomic) GKStateMachine * stateMachine;
@end

@implementation GameScene
-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    
//    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"monster"];
//    SKTexture *f1 = [atlas textureNamed:@"monster-walk1.png"];
//    SKTexture *f2 = [atlas textureNamed:@"monster-walk2.png"];
//    SKTexture *f3 = [atlas textureNamed:@"monster-walk3.png"];
//    SKTexture *f4 = [atlas textureNamed:@"monster-walk4.png"];
//    NSArray *monsterWalkTextures = @[f1,f2,f3,f4];
//
//    [SKTexture preloadTextures:monsterWalkTextures withCompletionHandler:^
//     {//textures加载完成后进入
//         // The textures are loaded into memory. Start the level.
//         HelloScene * hello = [[HelloScene alloc] initWithSize:self.view.frame.size];
//         SKView * spriteView = (SKView *)self.view;
//         SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:0.5];
//         [spriteView presentScene:hello transition:doors];
//     }];
    
//    HelloScene * hello = [[HelloScene alloc] initWithSize:self.view.frame.size];
//    SKView * spriteView = (SKView *)self.view;
//    SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:0.5];
//    [spriteView presentScene:hello transition:doors];

    NSArray *obstacles =[NSArray arrayWithObject:[self childNodeWithName:@"obstacles"]];
    NSArray *polygonObstacles = [SKNode obstaclesFromNodeBounds:obstacles];
    self.graph = [GKObstacleGraph graphWithObstacles:polygonObstacles bufferRadius:10.0f];
    [self setUpEntities];
    [self setUpState];
    [self setUpRuleSystem];
    
    SKNode * hero = [self childNodeWithName:@"hero"];
    hero.physicsBody.categoryBitMask = heroCategory;
    hero.physicsBody.contactTestBitMask = heroCategory;
    hero.physicsBody.collisionBitMask = heroCategory;
    SKNode * enemy = [self childNodeWithName:@"enemy1"];
    enemy.physicsBody.categoryBitMask = enemyCategory;
    enemy.physicsBody.contactTestBitMask = enemyCategory;
    enemy.physicsBody.collisionBitMask = enemyCategory;
    self.physicsWorld.contactDelegate = self;

}

- (BOOL)isTargetVisibleAtPoint:(CGPoint)endpoint
{
    SKNode * hero = [self childNodeWithName:@"hero"];
    CGPoint rayStart = hero.position;
    CGPoint rayEnd = endpoint;
    
    SKPhysicsBody *body = [self.physicsWorld bodyAlongRayStart:rayStart end:rayEnd];
    return (body && body.categoryBitMask == enemyCategory);
}

-(void)setUpRuleSystem
{
//    /* Make a rule system */
//    GKRuleSystem* sys = [[GKRuleSystem alloc] init];
//    /* Getting distance and asserting facts */
//    float distance = [sys.state[@"distance"] floatValue];
//    [sys assertFact:@"close" grade:1.0f - distance / 2];
//    [sys assertFact:@"far" grade:distance / 2];
//    /* Grade our facts - farness and closeness */
//    float farness = [sys gradeForFact:@"far"];
//    float closeness = [sys gradeForFact:@"close"];
//    /* Derive Fuzzy acceleration */
//    float fuzzyAcceleration = farness - closeness;
    
    GKRuleSystem * ruleSystem = [[GKRuleSystem alloc] init];
    NSPredicate * playerFar = [NSPredicate predicateWithFormat:@"$distanceToPlayer.floatValue >= 10.0"];
    [ruleSystem addRule:[GKRule ruleWithPredicate:playerFar assertingFact:@"hunt" grade:1.0]];
    NSPredicate * playerNear = [NSPredicate predicateWithFormat:@"$distanceToPlayer.floatValue < 10.0"];
    [ruleSystem addRule:[GKRule ruleWithPredicate:playerNear retractingFact:@"hunt" grade:1.0]];

    NSUInteger distanceToPlayer = 10;
    ruleSystem.state[@"distanceToPlayer"]= @(distanceToPlayer);
    
    [ruleSystem reset];
    [ruleSystem evaluate];
    
    BOOL hunting = [ruleSystem gradeForFact:@"hunt"] > 2;
    
}

-(void)setUpState
{
    state1 * stateOne = [state1 state];
    state2 * stateTwo = [state2 state];
    
    self.stateMachine = [GKStateMachine stateMachineWithStates:@[stateOne,stateTwo]];
    [self.stateMachine enterState:state1.class];
    [self.stateMachine updateWithDeltaTime:1];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    for (colorComponent * comp in self.enemysComponentSystem.components) {
        [comp changeColor];
    }
    
    UITouch * touch = [touches anyObject];
//    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        NSLog(@"location x= %f ,y= %f",location.x,location.y);
        
        SKNode * hero = [self childNodeWithName:@"hero"];
        [hero removeAllActions];
        GKGraphNode2D * startNode = [GKGraphNode2D nodeWithPoint:(vector_float2){hero.position.x,hero.position.y}];
        GKGraphNode2D * endNode = [GKGraphNode2D nodeWithPoint:(vector_float2){location.x,location.y}];
        [self.graph connectNodeUsingObstacles:startNode];
        [self.graph connectNodeUsingObstacles:endNode];
        NSArray * path = [self.graph findPathFromNode:startNode toNode:endNode];
        if (path.count <1) {
            return;
        }
        moveForPathNode(path,hero);
        GKPath * pathGk = [GKPath pathWithGraphNodes:path radius:10.0f];
        [self.graph removeNodes:@[startNode,endNode]];
//    }
    
    
    //GKRandomDistribution得到的结果在规定的范围内几率相同
    GKRandomDistribution * d6 = GKRandomDistribution.d6;
    NSInteger res = d6.nextInt;
    GKRandomDistribution * d8 = [GKRandomDistribution distributionWithLowestValue:1 highestValue:8];//自定义数量
    NSInteger res8 = d8.nextInt;
    //GKGaussianDistribution得到的结果在规定的范围内取中间值左右的几率大
    GKGaussianDistribution * d20 = GKGaussianDistribution.d20;
    NSInteger choice = d20.nextInt;//0~20范围取到11左右的几率最大
    //GKShuffledDistribution
    GKShuffledDistribution * d9 = [GKShuffledDistribution distributionWithLowestValue:1 highestValue:9];
    NSInteger choice9 = d9.nextInt;//0~20范围几率相同
    NSInteger secondChoice9 = d9.nextInt;//再次，得到与之前的值（choice）不一样的的结果
    
    NSLog(@"GKRandomDistribution d6= %ld;;\nGKRandomDistribution d8=%ld;;\nGKGaussianDistribution d20 choice= %ld;;\nGKShuffledDistribution d9 choice9= %ld,secondChoice9 =%ld",res,res8,choice,choice9,secondChoice9);

    NSArray * deck = @[@"Ace", @"king", @"Queen", @"Jack", @"Ten"];
    deck = [[GKRandomSource sharedRandom] arrayByShufflingObjectsInArray:deck];/* possible result - [Jack, King, Ten, Queen, Ace] */
    NSLog(@"洗牌 ＝ %@",deck);
    
    
    
    
    [self.stateMachine enterState:state2.class];
    
    BOOL isenemy = [self isTargetVisibleAtPoint:location];
    NSLog(@"hero see enemy is %d",isenemy);
}

void rotateSprite(SKSpriteNode * Sprite,CGPoint direction) {//旋转
    Sprite.zRotation = atan2(direction.y-Sprite.position.y, direction.x-Sprite.position.x);
    NSLog(@"sprite.zrotation = %f",Sprite.zRotation);
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

-(void)didBeginContact:(SKPhysicsContact *)contact
{
//    SKPhysicsBody* firstBody;
//    
//    SKPhysicsBody* secondBody;
    
    // 2 始终把类别代码较小的物体赋给firstBody变量
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        
//        firstBody = contact.bodyA;
//        
//        secondBody = contact.bodyB;
        
    } else {
        
//        firstBody = contact.bodyB;
//        
//        secondBody = contact.bodyA;
        
    }
    

}

void addFollowAndStayOnPathGoalsForPath(GKPath * path){
    
}

-(void)setUpEntities {
    SKSpriteNode * hero = (SKSpriteNode *)[self childNodeWithName:@"hero"];
    SKSpriteNode * enemy1 = (SKSpriteNode *)[self childNodeWithName:@"enemy1"];
    SKSpriteNode * enemy2 = (SKSpriteNode *)[self childNodeWithName:@"enemy2"];

    //一种写法
//    hero = ({
//        SKNode * node = [[SKNode alloc]init];
//        node.scene.size = CGSizeMake(30, 30);
//        node;
//    });
//    
//    UIView * view = ({
//        [[UIView alloc] init];
//    });
    
    //Entity需要持久保存，当前demo的实体保存在self.arrayEntitys中
    GKEntity * heroBox = [[GKEntity alloc] init];
    GKEntity * enemy1Box = [[GKEntity alloc] init];
    GKEntity * enemy2Box = [[GKEntity alloc] init];

    colorComponent * ColorComponentU = [[colorComponent alloc] init];
    colorComponent * ColorComponent2 = [[colorComponent alloc] init];

    sizeComponent * SizeComponent = [[sizeComponent alloc] init];
    SizeComponent.size = CGSizeMake(100, 100);
    
    ColorComponentU.spriteNode = hero;
    [heroBox addComponent:ColorComponentU];
    [heroBox addComponent:SizeComponent];
    
    ColorComponentU.spriteNode = enemy1;
    [enemy1Box addComponent:ColorComponentU];
    [enemy1Box addComponent:SizeComponent];

    ColorComponent2.spriteNode = enemy2;
    [enemy2Box addComponent:ColorComponent2];
    [enemy2Box addComponent:SizeComponent];
    
    self.enemysComponentSystem = [[GKComponentSystem alloc] initWithComponentClass:[colorComponent class]];
    [self.enemysComponentSystem addComponentWithEntity:enemy1Box];
    [self.enemysComponentSystem addComponentWithEntity:enemy2Box];
    
    [self.enemysComponentSystem updateWithDeltaTime:0];
    
    self.arrayEntitys = [NSMutableArray array];
    [self.arrayEntitys addObject:heroBox];
    [self.arrayEntitys addObject:enemy1Box];
    [self.arrayEntitys addObject:enemy2Box];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    float dt = currentTime - self.prevUpdateTime;
    self.prevUpdateTime = currentTime;
//    [self.enemysComponentSystem updateWithDeltaTime:dt];
}

-(void)didEvaluateActions
{

}
@end
