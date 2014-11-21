//
//  RMUserCell.m
//  Redmadrobot
//
//  Created by Dmitry Shashlov on 11/18/14.
//  Copyright (c) 2014 Dmitry Shashlov. All rights reserved.
//

#import "RMUserCell.h"
#import "RMAvatarView.h"
#import <InstagramKit/InstagramUser.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
static CGFloat kVerticalOffset = kGridSize * 2;
static CGFloat kVerticalPadding = kGridSize;
static CGFloat kHorizontalOffset = kGridSize * 2;
static CGFloat kHorizontalPadding = kGridSize;
#pragma clang diagnostic pop

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface RMUserCell()
@property (nonatomic) RMAvatarView *avatarView;
@property (nonatomic) UILabel *usernameLabel;
@property (nonatomic) UILabel *fullnameLabel;
@end

@implementation RMUserCell

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Init

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self)
  {
    // Avatar
    _avatarView = [[RMAvatarView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_avatarView];
    
    // Username
    _usernameLabel = [UILabel newAutoLayoutView];
    _usernameLabel.font = [UIFont boldSystemFontOfSize:19.0f];
    [self.contentView addSubview:_usernameLabel];
    
    // Fullname
    _fullnameLabel = [UILabel newAutoLayoutView];
    _fullnameLabel.font = [UIFont systemFontOfSize:17.0f];
    [self.contentView addSubview:_fullnameLabel];
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Reuse

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)prepareForReuse
{
  [super prepareForReuse];
  [_avatarView prepareForReuse];
  _usernameLabel.text = nil;
  _fullnameLabel.text = nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Update

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateWithUser:(InstagramUser *)user
{
  [_avatarView updateWithUser:user];
  _usernameLabel.text = user.username;
  _fullnameLabel.text = user.fullName;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Constraints

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setupConstraints
{
  [super setupConstraints];
  
  [_avatarView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kVerticalOffset];
  [_avatarView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:kHorizontalOffset];
  [_avatarView autoSetDimensionsToSize:CGSizeMake(40.0f, 40.0f)];
  
  [_usernameLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kVerticalOffset];
  [_usernameLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_avatarView withOffset:kHorizontalPadding];
  [_usernameLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:kHorizontalOffset];
  
  [_fullnameLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_usernameLabel];
  [_fullnameLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_avatarView withOffset:kHorizontalPadding];
  [_fullnameLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:kHorizontalOffset];
  [_fullnameLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kVerticalOffset relation:NSLayoutRelationGreaterThanOrEqual];
}

@end
