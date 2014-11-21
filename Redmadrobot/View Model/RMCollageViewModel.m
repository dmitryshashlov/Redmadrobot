//
//  RMCollageViewModel.m
//  Redmadrobot
//
//  Created by Dmitry Shashlov on 11/19/14.
//  Copyright (c) 2014 Dmitry Shashlov. All rights reserved.
//

#import "RMCollageViewModel.h"
#import "RMCollageScene.h"
#import <objc/runtime.h>
#import <InstagramKit/InstagramMedia.h>

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation RMCollageViewModel

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Init

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCollage:(RMCollage *)collage
{
  self = [super init];
  if (self)
  {
    _collage = collage;    
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (RMCollageScene *)sceneForProductionStep:(RMCollageProductionStep)step withSize:(CGSize)size
{
  RMCollageScene *scene = [[RMCollageScene alloc] initWithCollage:_collage productionStep:step size:size];
  return scene;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)buildCollageImageWithSize:(CGSize)size completionBlock:(void (^)(UIImage *))completionBlock
{
  // All groups
  NSMutableArray *imageLoadSignals = [[NSMutableArray alloc] init];
  for (RMCollageGroup *group in _collage.groups) {
    RACSignal *imageLoadSignal = [NSData rac_readContentsOfURL:group.media.standardResolutionImageURL
                                                       options:0
                                                     scheduler:[RACScheduler schedulerWithPriority:RACSchedulerPriorityBackground]];
    [imageLoadSignals addObject:imageLoadSignal];
    [imageLoadSignal
     subscribeNext:^(NSData *data) {
       UIImage *image = [UIImage imageWithData:data];
       objc_setAssociatedObject(group, _cmd, image, OBJC_ASSOCIATION_RETAIN);
     }];
  }
  
  // When every image loaded
  [[RACSignal merge:imageLoadSignals]
   subscribeCompleted:^{
     
     NSMutableArray *groupImages = [[NSMutableArray alloc] init];
     for (RMCollageGroup *group in _collage.groups)
     {
       // Create graphics context
       UIGraphicsBeginImageContext(size);
       CGContextRef context = UIGraphicsGetCurrentContext();
       CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
       
       // Calculate rects
       CGRect groupRect = [self rectForGroup:group size:size];
       CGSize imageSize = CGSizeMake(MAX(groupRect.size.width, groupRect.size.height),
                                     MAX(groupRect.size.width, groupRect.size.height));
       CGRect imageRect = CGRectMake(groupRect.origin.x - imageSize.width + groupRect.size.width,
                                     groupRect.origin.y - imageSize.height + groupRect.size.height,
                                     imageSize.width,
                                     imageSize.height);
       
       // Clip context
       CGContextClipToRect(context, groupRect);
       
       // Draw image
       UIImage *groupImage = objc_getAssociatedObject(group, _cmd);
       [groupImage drawInRect:imageRect];
       
       // Stroke outline
       CGContextStrokeRect(context, groupRect);

       // Store group image
       UIImage *maskedGroupImage = UIGraphicsGetImageFromCurrentImageContext();
       [groupImages addObject:maskedGroupImage];
       UIGraphicsEndImageContext();
     }
     
     // Merge all groups together
     UIGraphicsBeginImageContext(size);
     for (UIImage *image in groupImages) {
       [image drawAtPoint:CGPointZero];
     }
     UIImage *collageImage = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
     
     if (completionBlock)
       completionBlock(collageImage);
   }];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)rectForGroup:(RMCollageGroup *)group size:(CGSize)size
{
  CGRect groupRect = CGRectZero;
  for (RMCollageSector *sector in group.sectors)
  {
    CGRect sectorRect = [self rectForIndexPath:sector.indexPath size:size];
    if (groupRect.origin.x == 0 & groupRect.origin.y == 0 && groupRect.size.width == 0 && groupRect.size.height == 0)
      groupRect = sectorRect;
    else
      groupRect = CGRectUnion(groupRect, sectorRect);
  }
  
  return groupRect;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)rectForIndexPath:(NSIndexPath *)indexPath size:(CGSize)size
{
  CGFloat gridStep = size.width / _collage.size.intValue;
  return CGRectMake(indexPath.row * gridStep,
                    size.height - gridStep - indexPath.section * gridStep,
                    gridStep,
                    gridStep);
}

@end
