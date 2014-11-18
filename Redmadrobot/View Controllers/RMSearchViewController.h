//
//  RMSearchViewController.h
//  Redmadrobot
//
//  Created by Dmitry Shashlov on 11/18/14.
//  Copyright (c) 2014 Dmitry Shashlov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <InstagramKit/InstagramUser.h>

@interface RMSearchViewController : UITableViewController <
  UISearchDisplayDelegate
>

@property (nonatomic) InstagramUser *selectedUser;

@end
