//
//  RMCollageViewController.h
//  Redmadrobot
//
//  Created by Dmitry Shashlov on 11/19/14.
//  Copyright (c) 2014 Dmitry Shashlov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMCollageViewModel.h"

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@class RMCollageViewController, InstagramUser;

@protocol RMCollageViewControllerDelegate <NSObject>

- (void)collageControllerDidFinish:(RMCollageViewController *)collageController;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface RMCollageViewController : UIViewController <
  UICollectionViewDelegate,
  UICollectionViewDataSource
>

- (id)initWithCollage:(RMCollage *)collage productionStep:(RMCollageProductionStep)step;

@property (nonatomic, readonly) RMCollageViewModel *collageViewModel;
@property (nonatomic, readonly) RMCollageProductionStep step;
@property (nonatomic) id <RMCollageViewControllerDelegate> collageDelegate;
@property (nonatomic) InstagramUser *user;
@property (nonatomic, readonly) UIImage *collageImage;
@property (nonatomic) RMCollageShareType shareType;

@end
