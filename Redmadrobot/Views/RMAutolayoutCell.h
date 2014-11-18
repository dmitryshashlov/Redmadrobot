//
//  RMAutolayoutCell.h
//  Redmadrobot
//
//  Created by Dmitry Shashlov on 11/18/14.
//  Copyright (c) 2014 Dmitry Shashlov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PureLayout/PureLayout.h>

@interface RMAutolayoutCell : UITableViewCell

- (void)setupConstraints;
- (void)clearConstraints;
- (void)layoutWithWidth:(CGFloat)width;

@end
