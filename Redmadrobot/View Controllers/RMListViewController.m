//
//  RMListViewController.m
//  Redmadrobot
//
//  Created by Dmitry Shashlov on 11/19/14.
//  Copyright (c) 2014 Dmitry Shashlov. All rights reserved.
//

#import "RMListViewController.h"
#import "RMComposeViewController.h"
#import "UIActionSheet+Share.h"
#import "RMCollageCell.h"

static NSString * const kUDCollages = @"collages";

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface RMListViewController ()
@property (nonatomic) NSMutableArray *collages;
@end

@implementation RMListViewController

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Init

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  if (self)
  {
    _collages = [[NSMutableArray alloc] initWithArray:[RMCollage savedCollages]];
    
    // Title
    self.title = NSLocalizedString(@"Collages", nil);
    
    // New bar button item
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"New", nil)
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(actionAdd:)];
    self.navigationItem.rightBarButtonItem = addItem;
    
    // Observe collages
    @weakify(self);
    [RACObserve(self, collages)
     subscribeNext:^(id x) {
       @strongify(self);
       [self.tableView reloadData];
     }];
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Table view

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return _collages.count;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 313.0f;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *cellIdentifier = @"CollageCell";
  RMCollageCell *collageCell = (RMCollageCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (!collageCell)
    collageCell = [[RMCollageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
  collageCell.collage = [_collages objectAtIndex:indexPath.row];
  return collageCell;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  UIActionSheet *shareSheet = [UIActionSheet shareActionSheetWithBlock:^(NSNumber *shareType) {
    RMCollage *collage = [_collages objectAtIndex:indexPath.row];
    [self shareImage:collage.previewImage withType:shareType.intValue];
  }];
  [shareSheet showInView:self.view];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Actions

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)actionAdd:(id)sender
{
  RMComposeViewController *composeController = [[RMComposeViewController alloc] init];
  composeController.composeDelegate = self;
  [self presentViewController:composeController animated:YES completion:nil];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Compose Controller Delegate

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)composeControllerDidCancel:(RMComposeViewController *)composeController
{
  [self dismissViewControllerAnimated:YES completion:nil];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)composeControllerDidFinish:(RMComposeViewController *)composeController
{
  [self dismissViewControllerAnimated:YES completion:nil];
  
  // Send image
  @weakify(self);
  [[[RACObserve(composeController, collageImage)
     filter:^BOOL(UIImage *collageImage) {
       return collageImage != nil;
     }] deliverOn:[RACScheduler mainThreadScheduler]]
   subscribeNext:^(UIImage *collageImage) {
     @strongify(self);
     
     // Save colage
     RMCollage *collage = composeController.collage;
     collage.previewImage = collageImage;
     [collage save];
     
     // Add to collages
     NSMutableArray *collagesMutable = [self mutableArrayValueForKeyPath:@"collages"];
     [collagesMutable addObject:collage];
     
     // Share
     [self shareImage:collageImage withType:composeController.shareType];
   }];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)shareImage:(UIImage *)collageImage withType:(RMCollageShareType)shareType
{
  switch (shareType) {
    case RMCollageShareTypeGallery:
      UIImageWriteToSavedPhotosAlbum(collageImage, nil, nil, NULL);
      break;
      
    case RMCollageShareTypeMail:
    {
      if ([MFMailComposeViewController canSendMail])
      {
        MFMailComposeViewController *mailComposeController = [[MFMailComposeViewController alloc] init];
        mailComposeController.mailComposeDelegate = self;
        [mailComposeController setSubject:@"Instagram collage"];
        [mailComposeController setToRecipients:@[@"01001010@redmadrobot.com"]];
        [mailComposeController setMessageBody:@"What a great collage!" isHTML:NO];
        [mailComposeController addAttachmentData:UIImageJPEGRepresentation(collageImage, 0.9f)
                                        mimeType:@"image/jpeg"
                                        fileName:@"collage"];
        [self presentViewController:mailComposeController animated:YES completion:nil];
      }
      else
      {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Mail account"
                                                            message:@"Please configure Mail account to be able to send emails\n\nWould you like to save collage to Camera Roll?"
                                                           delegate:nil
                                                  cancelButtonTitle:@"No"
                                                  otherButtonTitles:@"Yes", nil];
        
        [[alertView rac_buttonClickedSignal]
         subscribeNext:^(NSNumber *buttonIndex) {
           if (buttonIndex.intValue == 1)
             UIImageWriteToSavedPhotosAlbum(collageImage, nil, nil, NULL);
         }];
        [alertView show];
      }
      break;
    }
      
    case RMCollageShareTypeUndefined:
    default:
      break;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Mail Compose Controller Delegate

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
