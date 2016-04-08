//
//  GameViewController.m
//  AceHunter
//
//  Created by 123 on 16/3/9.
//  Copyright (c) 2016年 star. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
@interface GameViewController ()

@end

@implementation GameViewController
{
    GameScene *sceneAceHunter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = YES;
    
    // Create and configure the scene.
    GameScene *scene = [GameScene nodeWithFileNamed:@"GameScene"];
    [scene setSize:self.view.frame.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    sceneAceHunter = scene;

    // Present the scene.
    [skView presentScene:scene];
}

- (IBAction)dodgeAction:(UISwipeGestureRecognizer *)sender {
    //根据轻扫方向，进行不同控制
    switch (sender.direction) {
        case UISwipeGestureRecognizerDirectionRight: {
            sceneAceHunter.heroDodge(UISwipeGestureRecognizerDirectionRight);
            break;
        }
        case UISwipeGestureRecognizerDirectionLeft: {
            sceneAceHunter.heroDodge(UISwipeGestureRecognizerDirectionLeft);
            break;
        }
        case UISwipeGestureRecognizerDirectionUp: {
            sceneAceHunter.heroDodge(UISwipeGestureRecognizerDirectionUp);
            break;
        }
        case UISwipeGestureRecognizerDirectionDown: {
            sceneAceHunter.heroDodge(UISwipeGestureRecognizerDirectionDown);
            break;
        }
    }

}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
