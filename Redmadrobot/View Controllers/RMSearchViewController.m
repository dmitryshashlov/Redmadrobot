//
//  RMSearchViewController.m
//  Redmadrobot
//
//  Created by Dmitry Shashlov on 11/18/14.
//  Copyright (c) 2014 Dmitry Shashlov. All rights reserved.
//

#import "RMSearchViewController.h"
#import <InstagramKit/InstagramEngine.h>
#import <InstagramKit/InstagramUser.h>
#import "RMUserCell.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface RMSearchViewController ()
@property (nonatomic) NSString *prevSearchString;
@property (nonatomic) NSArray *users;
@property (nonatomic) NSTimer *searchTimer;
@property (nonatomic) UISearchDisplayController *searchController;
@end

@implementation RMSearchViewController

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - View

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // Search bar
  UISearchBar *searchBar = [[UISearchBar alloc] init];
  searchBar.placeholder = @"Search user";
  self.navigationItem.titleView = searchBar;
  
  // Search controller
  self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
  self.searchController.delegate = self;
  self.searchController.searchResultsDelegate = self;
  self.searchController.searchResultsDataSource = self;
  self.searchController.displaysSearchBarInNavigationBar = YES;
  
  // Hide toolbar
  [self.navigationController setToolbarHidden:YES animated:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Table view controller

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  
  return 1;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return _users.count;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 72.0f;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *cellIdentifier = @"UserCell";
  RMUserCell *userCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (!userCell)
    userCell = [[RMUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
  
  InstagramUser *user = [_users objectAtIndex:indexPath.row];
  [userCell updateWithUser:user];
  [userCell layoutWithWidth:CGRectGetWidth(self.tableView.frame)];
  
  return userCell;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  self.selectedUser = [_users objectAtIndex:indexPath.row];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Search dislpay

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
  if (searchString.length > 2)
  {
    _prevSearchString = searchString;
    
    // Search timer
    [_searchTimer invalidate];
    _searchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                    target:self
                                                  selector:@selector(actionSearch)
                                                  userInfo:nil
                                                   repeats:NO];
  }
  else
  {
    self.users = nil;
    return YES;
  }
  
  return NO;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Actions

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)actionSearch
{
  [_searchTimer invalidate];
  _searchTimer = nil;

  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
  [[InstagramEngine sharedEngine] searchUsersWithString:_prevSearchString
                                            withSuccess:^(NSArray *users, InstagramPaginationInfo *paginationInfo) {
                                              [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                              self.users = users;
                                              if (users.count)
                                              {
                                                [_searchController setActive:YES animated:YES];
                                                [_searchController.searchResultsTableView reloadData];
                                              }
                                            }
                                                failure:^(NSError *error) {
                                                  NSLog(@"%@", error.localizedDescription);
                                                }];
}

@end
