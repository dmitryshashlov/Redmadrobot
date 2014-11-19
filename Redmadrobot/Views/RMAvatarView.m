//
//  RMAvatarView.m
//  Redmadrobot
//
//  Created by Dmitry Shashlov on 11/18/14.
//  Copyright (c) 2014 Dmitry Shashlov. All rights reserved.
//

#import "RMAvatarView.h"
#import <InstagramKit/InstagramUser.h>

static UIImage * __kDefaultAvatarImage;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation RMAvatarView

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)load
{
  [super load];
  __kDefaultAvatarImage = [UIImage imageNamed:@"Avatar"];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Init

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self)
  {
    self.image = __kDefaultAvatarImage;
    self.shadowRadius = 1.0f;
    self.borderWidth = 2.0f;
    self.borderColor = [UIColor whiteColor];
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Reuse

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)prepareForReuse
{
  self.image = __kDefaultAvatarImage;
  [_imageLoadDisposable dispose];
  _imageLoadDisposable = nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Update

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateWithUser:(InstagramUser *)user
{
  RACSignal *imageLoadSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
    [[NSData rac_readContentsOfURL:user.profilePictureURL
                           options:0
                         scheduler:[RACScheduler schedulerWithPriority:RACSchedulerPriorityBackground]]
     subscribeNext:^(NSData *data) {
       [subscriber sendNext:[UIImage imageWithData:data]];
       [subscriber sendCompleted];
     } error:^(NSError *error) {
       [subscriber sendError:error];
     }];
    
    return nil;
  }];
  
  _imageLoadDisposable = [imageLoadSignal subscribeNext:^(UIImage *image) {
    dispatch_async(dispatch_get_main_queue(), ^{
      self.image = image;
    });
  }];
}

@end
