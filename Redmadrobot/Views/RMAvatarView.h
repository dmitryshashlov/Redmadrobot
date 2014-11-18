//
//  RMAvatarView.h
//  Redmadrobot
//
//  Created by Dmitry Shashlov on 11/18/14.
//  Copyright (c) 2014 Dmitry Shashlov. All rights reserved.
//

#import "AMPAvatarView.h"

@class InstagramUser;

@interface RMAvatarView : AMPAvatarView

- (void)updateWithUser:(InstagramUser *)user;
- (void)prepareForReuse;

@property (nonatomic) RACDisposable *imageLoadDisposable;

@end
