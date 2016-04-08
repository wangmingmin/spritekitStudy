//
//  HelloScene.m
//  spritekitStudy
//
//  Created by 123 on 16/2/25.
//  Copyright © 2016年 star. All rights reserved.
//

#import "HelloScene.h"
#define helloNodeName @"helloNode"

@interface HelloScene ()
@property BOOL contentCreated;
@end

@implementation HelloScene
-(void)didMoveToView:(SKView *)view
{
    if (!self.contentCreated) {
        [self createSceneContents];
        self.contentCreated = YES;
    }
    
    SKSpriteNode *spaceship = [self newSpaceship];
    [self addChild:spaceship];

//    SKSpriteNode *button = [SKSpriteNode spriteNodeWithImageNamed:@"test"];
//    button.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
//    button.centerRect = CGRectMake(60.0/128.0, 60.0/128.0, 16.0/128.0, 16.0/128.0);//类似于9切片技术，圆角长宽60、60，中心长宽16、16
//    button.size = CGSizeMake(320, 128);
//    [self addChild:button];
    
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"monster"];
    SKTexture *f1 = [atlas textureNamed:@"monster-walk1.png"];
    SKTexture *f2 = [atlas textureNamed:@"monster-walk2.png"];
    SKTexture *f3 = [atlas textureNamed:@"monster-walk3.png"];
    SKTexture *f4 = [atlas textureNamed:@"monster-walk4.png"];
    NSArray *monsterWalkTextures = @[f1,f2,f3,f4];
    
    SKTexture *bottomLeftTexture = [SKTexture textureWithRect:CGRectMake(0.0,0.0,0.5,0.5) inTexture:f1];
    SKAction *walkAnimation = [SKAction animateWithTextures:monsterWalkTextures timePerFrame:0.1];
    SKSpriteNode *monster = [SKSpriteNode spriteNodeWithTexture:bottomLeftTexture];
    [monster runAction:walkAnimation];

//    self.physicsWorld.gravity = CGVectorMake(0,0);
//    vector_float3 gravityVector = {0,-1,0};
//    SKFieldNode *gravityNode = [SKFieldNode linearGravityFieldWithVector: gravityVector];
//    gravityNode.strength = 9.8;
//    [self addChild:gravityNode];
//    gravityNode.zRotation = M_PI_4; // Flip gravity.
    [self ConstraintWithSpaceship];
}

-(void)createSceneContents
{
    //edge loop body 是一个静态的物理实体(比如，它不可以移动)。正如名字所暗示的那样，一个 edge loop 仅仅定义了一个形状的边界。它没有质量，不能和其他 edge loop bodies 产生碰撞，并且它也不从不会被物理仿真系统移动。其他的物体可以在这个边界的内部或者外部。
    //我们最常使用 edge loop 的是定义碰撞冲突的区域来描述你的游戏的边界、地面、墙体、触发区域或者其他类型的不可移动的碰撞冲突区域。
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
//    CGMutablePathRef trianglePath = CGPathCreateMutable();
//    CGPathMoveToPoint(trianglePath, nil, self.frame.size.width/2.0, self.frame.size.height);
//    CGPathAddLineToPoint(trianglePath, nil, 0, 50);
//    CGPathAddLineToPoint(trianglePath, nil, self.frame.size.width, 50);
//    CGPathAddLineToPoint(trianglePath, nil, self.frame.size.width/2.0, self.frame.size.height);
//    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromPath:trianglePath];
//    CGPathRelease(trianglePath);
    
    self.backgroundColor = [SKColor blueColor];
    self.scaleMode = SKSceneScaleModeAspectFill;
    [self addChild:[self newHelloNode]];
}

-(SKLabelNode *)newHelloNode
{
    SKLabelNode * helloNode = [SKLabelNode labelNodeWithFontNamed:@"chalkduster"];
    helloNode.name = helloNodeName;
    helloNode.text = @"Hello World !";
    helloNode.fontSize = 22;
    helloNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    return helloNode;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    SKNode * helloNode = [self childNodeWithName:helloNodeName];
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        if (helloNode != nil) {
            helloNode.name = nil;
            SKAction * moveUp = [SKAction moveByX:0 y:100.0 duration:0.5];
            SKAction * zoom = [SKAction scaleTo:2.0 duration:0.25];
            SKAction * pause = [SKAction waitForDuration:0.5];
            SKAction * fadeAway = [SKAction fadeOutWithDuration:0.25];
            SKAction * remove = [SKAction removeFromParent];
            
            SKAction * moveSequence = [SKAction sequence:@[moveUp,zoom,pause,fadeAway,remove]];
            [helloNode runAction:moveSequence];
        }
    }
}

#pragma spaceship
- (SKSpriteNode *)newSpaceship
{
//    SKTexture *rocketTexture = [SKTexture textureWithImageNamed:@"Spaceship.png"];
//    SKSpriteNode *rocket = [SKSpriteNode spriteNodeWithTexture:rocketTexture];
//    rocket.position = CGPointMake(200,200);
//    [self addChild: rocket];

    SKSpriteNode *hull = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
    hull.name = @"spaceship";
    SKAction *pulseYellow = [SKAction sequence:@[
                                              [SKAction colorizeWithColor:[SKColor yellowColor] colorBlendFactor:1.0 duration:0.15],
                                              [SKAction waitForDuration:0.1],
                                              [SKAction colorizeWithColorBlendFactor:0.0 duration:0.15]]];
    [hull runAction:[SKAction repeatActionForever:pulseYellow]];
    
    hull.size = CGSizeMake(64,32);
    hull.position = CGPointMake(100,100);

    SKAction *hover = [SKAction sequence:@[
                                           [SKAction waitForDuration:1.0],
                                           [SKAction moveByX:50 y:150.0 duration:1.0],
                                           [SKAction waitForDuration:1.0],
                                           [SKAction moveByX:-50.0 y:-150 duration:1.0]]];
    [hull runAction: [SKAction repeatActionForever:hover]];
    
    //group同时发生，sequence顺序发生
//    NSArray *textures = @[hull.texture];
//    SKAction *animate = [SKAction animateWithTextures:textures timePerFrame:2.0/textures.count];
//    SKAction *moveDown = [SKAction moveByX:0 y:-200 duration:2.0];
//    SKAction *scale = [SKAction scaleTo:1.0 duration:1.0];
//    SKAction *fadeIn = [SKAction fadeInWithDuration: 1.0];
//    SKAction *group = [SKAction group:@[animate, moveDown, scale, fadeIn]];

//    SKAction *fadeOut = [SKAction fadeOutWithDuration: 1];
//    SKAction *fadeIn = [SKAction fadeInWithDuration: 1];
//    SKAction *pulse = [SKAction sequence:@[fadeOut,fadeIn]];
//    SKAction *pulseThreeTimes = [SKAction repeatAction:pulse count:3];
//    SKAction *pulseForever = [SKAction repeatActionForever:pulse];

//    [self runAction:[SKAction repeatAction:[SKAction performSelector:@selector(someSelector) onTarget:self] count:100]];
    
    
    
    SKSpriteNode *light1 = [self newLight];
    light1.position = CGPointMake(-28.0, 6.0);
    [hull addChild:light1];
    
    SKSpriteNode *light2 = [self newLight];
    light2.position = CGPointMake(28.0, 6.0);
    [hull addChild:light2];
    
//    CGPoint positionInScene = [light1.scene convertPoint:light1.position fromNode:light1.parent];//坐标的相对位置
//    CGPoint positionInScene = [light1.scene convertPoint:light1.position toNode:light1.parent];
    
//    hull.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:hull.size];
//    hull.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:<#(nonnull CGPathRef)#>];
    hull.physicsBody = [SKPhysicsBody bodyWithTexture:hull.texture size:hull.size];
    hull.physicsBody.dynamic = NO;

    SKAction *makeRocks = [SKAction sequence: @[
                                                [SKAction performSelector:@selector(addRock) onTarget:self],
                                                [SKAction waitForDuration:0.10 withRange:0.15]
                                                ]];
    [self runAction: [SKAction repeatActionForever:makeRocks]];
    
    return hull;
}

-(void)ConstraintWithSpaceship//关联旋转
{
    SKNode * helloNode = [self childNodeWithName:helloNodeName];
    SKNode * spaceship = [self childNodeWithName:@"spaceship"];
    
    if (helloNode != nil && spaceship != nil) {
        SKConstraint * constraint1 = [SKConstraint orientToNode:spaceship offset:[SKRange rangeWithValue:3 variance:0]];
        helloNode.constraints = @[constraint1];
    }
}

- (SKSpriteNode *)newLight
{
    SKSpriteNode *light = [[SKSpriteNode alloc] initWithColor:[SKColor yellowColor] size:CGSizeMake(8,8)];
    
    SKAction *blink = [SKAction sequence:@[
                                           [SKAction fadeOutWithDuration:0.25],
                                           [SKAction fadeInWithDuration:0.25]]];
    SKAction *blinkForever = [SKAction repeatActionForever:blink];
    [light runAction: blinkForever];
    
    return light;
}


static inline CGFloat skRandf() {
    return rand() / (CGFloat) RAND_MAX;
}

static inline CGFloat skRand(CGFloat low, CGFloat high) {
    return skRandf() * (high - low) + low;
}

- (void)addRock
{
    SKSpriteNode *rock = [[SKSpriteNode alloc] initWithColor:[SKColor brownColor] size:CGSizeMake(8,8)];
    rock.position = CGPointMake(skRand(0, self.size.width), self.size.height-50);
    rock.name = @"rock";
    rock.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rock.size];
    rock.physicsBody.restitution = 1.0;
    //restitution属性描述了当物理实体从另一个物体上弹出时，还拥有多少能量。基本上我们更习惯称之为“反弹力”。它的取值介于0.0(完全不会反弹)到1.0(和物体碰撞反弹时所受的力与刚开始碰撞时的力的大小相同)之间。默认值是0.2。
    rock.physicsBody.usesPreciseCollisionDetection = YES;
    //启用精确冲突检测(usesPreciseCollisionDetection)：默认情况下，除非确实有必要，Sprite Kit 并不会启用精确的冲突检测，因为这样更快。但是不启用精确的冲突检测会有一个副作用，如果一个物体移动的非常快(比如一个子弹)，它可能会直接穿过其他物体。如果这种情况确实发生了，你就应该尝试启用更精确的冲突检测了。
    [self addChild:rock];
}

-(void)didSimulatePhysics
{
    [self enumerateChildNodesWithName:@"rock" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.y < 0)//(0,0)坐标点在左下角,y轴反向
            [node removeFromParent];
    }];
}

/*
 摩擦力(friction)：这个属性决定了物体的光滑程度。取值范围为从0.0(在表面滑动时，物体滑动很顺畅，就像小冰块似的)到1.0(在表面滑动时，物体会很快的停止)。默认值是0.2。
 
 动态性(dynamic)：有时候你想使物理实体可以碰撞检测，但是你想使用手动方式或者action的方式自己去移动物体。如果这就是你想要的结果，你可以简单的把这个属性设置为NO，物理引擎就会忽略所有作用在物理实体上的推力和脉冲力，让你自己负责物体的移动。
 
 启用精确冲突检测(usesPreciseCollisionDetection)：默认情况下，除非确实有必要，Sprite Kit 并不会启用精确的冲突检测，因为这样更快。但是不启用精确的冲突检测会有一个副作用，如果一个物体移动的非常快(比如一个子弹)，它可能会直接穿过其他物体。如果这种情况确实发生了，你就应该尝试启用更精确的冲突检测了。
 
 是否允许旋转(allowsRotation)：有些时候你可能想是你的精灵被物理引擎模拟，但是不想让它旋转。如果是这种情况，你可以简单的把这个标记为设置为NO就可以了。
 
 线速度阻尼(linerDamping)和角速度阻尼(angularDamping)：这些参数影响线速度和角速度随着时间衰减的多少。取值范围为0.0(速度从不衰减)到1.0(速度立即衰减)。默认值是0.1。
 
 是否受重力影响(affectedByGravity)：所有的物体默认情况都是受重力影响的，但是你可以简单的把这个标记位设置为NO，使其不受重力的影响。
 
 是否正在休息(resting)：物理引擎对于在一段时间内没有移动过的物体做了一个优化，把它们标记为"正在休息(resting)"，这样物理引擎就不需要再对它们进行计算了。如果你想要手动的唤醒一个正在休息(resting)的物体，简单的把这个标记位设置位NO即可。
 
 质量和区域(mass and area)：物理引擎会根据物理实体的形状和密度自动计算出这些属性。但是你也可以手动的去更改这些数值。
 
 density密度是根据单位体积的质量来定义的－－换言之，密度越高，体积越大，物体就会越重。密度的默认值是1.0，所以在这里你把沙子的密度提高到默认情况的20倍。
 
 节点(node)：物理实体有一个方便的指针，表示它所属于哪一个SKNode。
 */
@end
