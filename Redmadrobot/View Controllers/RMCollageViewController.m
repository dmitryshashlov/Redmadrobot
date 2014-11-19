//
//  RMCollageViewController.m
//  Redmadrobot
//
//  Created by Dmitry Shashlov on 11/19/14.
//  Copyright (c) 2014 Dmitry Shashlov. All rights reserved.
//

#import "RMCollageViewController.h"
#import <SpriteKit/SpriteKit.h>
#import "RMCollageScene.h"

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface RMCollageViewController()
@property (nonatomic) SKView *sceneView;
@property (nonatomic) RMCollageViewModel *collageViewModel;
@property (nonatomic) NSNumber *gridSize;
@end

@implementation RMCollageViewController

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Init

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCollage:(RMCollage *)collage productionStep:(RMCollageProductionStep)step
{
  self = [super init];
  if (self)
  {
    _collageViewModel = [[RMCollageViewModel alloc] initWithCollage:collage];
    _step = step;
    
    // Title
    switch (_step) {
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
    
    // Next bar button item
    switch (_step) {
      case RMCollageProductionStepGrid:
      case RMCollageProductionStepWireframe:
      {
        UIBarButtonItem *nextItem = [[UIBarButtonItem alloc] initWithTitle:@"Next"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(actionCompleted:)];
        self.navigationItem.rightBarButtonItem = nextItem;
        break;
      }
        
      case RMCollageProductionStepPick:
      {
        UIBarButtonItem *mailItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Mail"]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(actionCompleted:)];
        self.navigationItem.rightBarButtonItem = mailItem;
        break;
      }
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
  
  // Configuration
  self.view.backgroundColor = [UIColor whiteColor];
  
  // Scene view
  _sceneView = [[SKView alloc] initWithFrame:CGRectMake(0.0f,
                                                        self.navigationController.navigationBar.frame.size.height
                                                        + [UIApplication sharedApplication].statusBarFrame.size.height,
                                                        CGRectGetWidth(self.view.bounds),
                                                        CGRectGetWidth(self.view.bounds))];
  [self.view addSubview:_sceneView];
  
  // Configure
  [self configureViewForStep:_step];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  // Show toolbar
  [self.navigationController setToolbarHidden:NO animated:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];
  
  // Observe grid size changing
  [[[RACObserve(self, gridSize) distinctUntilChanged]
    filter:^BOOL(NSNumber *size) {
      return size != nil;
    }]
   subscribeNext:^(NSNumber *size) {
     self.collageViewModel = [[RMCollageViewModel alloc] initWithCollage:[[RMCollage alloc] initWithSize:size]];
   }];
  
  // Present scene
  if (!_sceneView.scene)
    [self presentScene];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Setters

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCollageViewModel:(RMCollageViewModel *)collageViewModel
{
  if (_collageViewModel.collage.size != collageViewModel.collage.size)
  {
    _collageViewModel = collageViewModel;
    if (self.isViewLoaded)
      [self presentScene];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)presentScene
{
  SKScene *scene = [_collageViewModel sceneForProductionStep:_step withSize:_sceneView.bounds.size];
  scene.scaleMode = SKSceneScaleModeAspectFill;
  [_sceneView presentScene:scene];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)configureViewForStep:(RMCollageProductionStep)step
{
  CGFloat collageOffset = (CGRectGetWidth(self.view.bounds) - kCollageSize.width) / 2;
  
  switch (step) {
    case RMCollageProductionStepGrid:
    {
      // Slider
      UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(collageOffset,
                                                                    _sceneView.frame.origin.y + CGRectGetWidth(self.view.bounds) + collageOffset,
                                                                    kCollageSize.width,
                                                                    21.0f)];
      slider.minimumValue = 2;
      slider.maximumValue = 7;
      
      // Observe control events
      [[slider rac_signalForControlEvents:UIControlEventValueChanged]
       subscribeNext:^(UISlider *slider) {
         slider.value = roundf(slider.value);
       }];
      
      // Observe value changing
      [RACObserve(slider, value)
       subscribeNext:^(NSNumber *value) {
         self.gridSize = @(roundf(value.floatValue));
       }];
      slider.value = _collageViewModel.collage.size.floatValue;
      
      // Add slider on toolbar
      UIBarButtonItem *sliderItem = [[UIBarButtonItem alloc] initWithCustomView:slider];
      [sliderItem setWidth:CGRectGetWidth(slider.bounds)];
      self.toolbarItems = @[sliderItem];

      break;
    }
      
    case RMCollageProductionStepWireframe:
    case RMCollageProductionStepPick:
    {
      // Reset button
      UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
      [resetButton setImage:[UIImage imageNamed:@"Reset"] forState:UIControlStateNormal];
      resetButton.frame = CGRectMake(collageOffset,
                                     _sceneView.frame.origin.y + CGRectGetWidth(self.view.bounds),
                                     kCollageSize.width,
                                     44.0f);
      [resetButton addTarget:self action:@selector(actionReset:) forControlEvents:UIControlEventTouchUpInside];
      
      // Add button on toolbar
      UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:resetButton];
      self.toolbarItems = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            buttonItem,
                            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
      
      break;
    }
      
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Actions

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)actionCompleted:(id)sender
{
  if ([_collageDelegate respondsToSelector:@selector(collageControllerDidFinish:)])
    [_collageDelegate collageControllerDidFinish:self];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)actionReset:(id)sender
{
  // TODO
}

@end
