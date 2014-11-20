//
//  RMComposeViewController.m
//  Redmadrobot
//
//  Created by Dmitry Shashlov on 11/19/14.
//  Copyright (c) 2014 Dmitry Shashlov. All rights reserved.
//

#import "RMComposeViewController.h"
#import "RMCollageViewController.h"
#import "RMSearchViewController.h"

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface RMComposeViewController ()
@property (nonatomic, readwrite) UIImage *collageImage;
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
  switch (collageController.step) {
    case RMCollageProductionStepGrid:
    {
      RMCollageViewController *nextStepController = [[RMCollageViewController alloc] initWithCollage:collageController.collageViewModel.collage
                                                                                      productionStep:RMCollageProductionStepWireframe];
      nextStepController.collageDelegate = self;
      [self pushViewController:nextStepController animated:YES];
      break;
    }
      
    case RMCollageProductionStepWireframe:
    {
      RMSearchViewController *searchController = [[RMSearchViewController alloc] initWithStyle:UITableViewStylePlain];
      [self pushViewController:searchController animated:YES];
      
      // Observe user picking
      [[RACObserve(searchController, selectedUser)
        filter:^BOOL(InstagramUser *user) {
          return user != nil;
        }]
       subscribeNext:^(InstagramUser *user) {
         RMCollageViewController *nextStepController = [[RMCollageViewController alloc] initWithCollage:collageController.collageViewModel.collage
                                                                                         productionStep:RMCollageProductionStepPick];
         nextStepController.collageDelegate = self;
         nextStepController.user = user;
         [self pushViewController:nextStepController animated:YES];
       }];
      
      break;
    }
    case RMCollageProductionStepPick:
    {
      if ([_composeDelegate respondsToSelector:@selector(composeControllerDidFinish:)])
        [_composeDelegate composeControllerDidFinish:self];
      
      // Show email controller
      [[RACObserve(collageController, collageImage)
       filter:^BOOL(UIImage *collageImage) {
         return collageImage != nil;
       }]
       subscribeNext:^(UIImage *collageImage) {
         self.collageImage = collageImage;
       }];
      
      break;
    }
  }
}

@end
