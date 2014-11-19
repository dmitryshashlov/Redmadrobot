//
//  RMCollageViewController.m
//  Redmadrobot
//
//  Created by Dmitry Shashlov on 11/19/14.
//  Copyright (c) 2014 Dmitry Shashlov. All rights reserved.
//

#import "RMCollageViewController.h"
#import <SpriteKit/SpriteKit.h>

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface RMCollageViewController()
@property (nonatomic) SKView *sceneView;
@end

@implementation RMCollageViewController

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Init

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCollageViewModel:(RMCollageViewModel *)collageViewModel productionStep:(RMCollageProductionStep)step;
{
  self = [super init];
  if (self)
  {
    _collageViewModel = collageViewModel;
    _step = step;
    
    // Title
    switch (step) {
      case RMCollageProductionStepGrid:
        self.title = NSLocalizedString(@"Grid size", nil);
        break;
        
      case RMCollageProductionStepWireframe:
        self.title = NSLocalizedString(@"Wireframe", nil);
        break;
                                       
      case RMCollageProductionStepPick:
        self.title = NSLocalizedString(@"Pick", nil);
        break;
    }
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - View

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
  [super viewDidLoad];
  _sceneView = [[SKView alloc] initWithFrame:CGRectMake(0.0f,
                                                        self.navigationController.navigationBar.frame.size.height
                                                        + [UIApplication sharedApplication].statusBarFrame.size.height,
                                                        CGRectGetWidth(self.view.bounds),
                                                        CGRectGetWidth(self.view.bounds))];
  [self.view addSubview:_sceneView];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];
  if (!_sceneView.scene)
  {
    // _sceneView.showsFPS = YES;
    // _sceneView.showsNodeCount = YES;
    
    SKScene *scene = [_collageViewModel sceneForProductionStep:_step withSize:_sceneView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    [_sceneView presentScene:scene];
  }
}

@end
