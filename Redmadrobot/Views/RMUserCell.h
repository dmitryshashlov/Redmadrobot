//
//  RMUserCell.h
//  Redmadrobot
//
//  Created by Dmitry Shashlov on 11/18/14.
//  Copyright (c) 2014 Dmitry Shashlov. All rights reserved.
//

#import "RMAutolayoutCell.h"

@class InstagramUser;

@interface RMUserCell : RMAutolayoutCell

- (void)updateWithUser:(InstagramUser *)user;

@end
