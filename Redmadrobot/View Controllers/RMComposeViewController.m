//
//  RMComposeViewController.m
//  Redmadrobot
//
//  Created by Dmitry Shashlov on 11/19/14.
//  Copyright (c) 2014 Dmitry Shashlov. All rights reserved.
//

#import "RMComposeViewController.h"
#import "RMCollageViewController.h"

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface RMComposeViewController ()

@end

@implementation RMComposeViewController

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Init

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCollage:(RMCollage *)collage step:(RMCollageProductionStep)step
{
  RMCollageViewController *collageController = [[RMCollageViewController alloc] initWithCollage:collage
                                                                                 productionStep:step];
  collageController.collageDelegate = self;
  
  self = [super initWithRootViewController:collageController];
  if (self)
  {
    _collage = collage;
    
    // Cancel
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(actionCancel:)];
    cancelItem.tintColor = [UIColor redColor];
    collageController.navigationItem.leftBarButtonItem = cancelItem;
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCollage:(RMCollage *)collage
{
  self = [self initWithCollage:collage
                          step:RMCollageProductionStepPick];
  if (self)
  {
    //
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init
{
  self = [self initWithCollage:[[RMCollage alloc] initWithSize:@3]
                          step:RMCollageProductionStepGrid];
  if (self)
  {
    //
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Actions

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)actionCancel:(id)sender
{
  if ([self.composeDelegate respondsToSelector:@selector(composeControllerDidCancel:)])
    [self.composeDelegate composeControllerDidCancel:self];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Collage Controller Delegate

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)collageControllerDidFinish:(RMCollageViewController *)collageController
{
  if (collageController.step < RMCollageProductionStepPick)
  {
    RMCollageViewController *nextStepController = [[RMCollageViewController alloc] initWithCollage:collageController.collageViewModel.collage
                                                                                    productionStep:collageController.step + 1];
    nextStepController.collageDelegate = self;
    [self pushViewController:nextStepController animated:YES];
  }
  else if ([_composeDelegate respondsToSelector:@selector(composeControllerDidFinish:)])
    [_composeDelegate composeControllerDidFinish:self];
}

@end
