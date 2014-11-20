//
//  RMListViewController.m
//  Redmadrobot
//
//  Created by Dmitry Shashlov on 11/19/14.
//  Copyright (c) 2014 Dmitry Shashlov. All rights reserved.
//

#import "RMListViewController.h"
#import "RMComposeViewController.h"

static NSString * const kUDCollages = @"collages";

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface RMListViewController ()
@property (nonatomic) NSArray *collages;
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
    _collages = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:kUDCollages]];
    
    // Title
    self.title = NSLocalizedString(@"Collages", nil);
    
    // New bar button item
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithTitle:@"New"
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(actionAdd:)];
    self.navigationItem.rightBarButtonItem = addItem;
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  RMCollage *collage = [_collages objectAtIndex:indexPath.row];
  RMComposeViewController *composeController = [[RMComposeViewController alloc] initWithCollage:collage];
  composeController.composeDelegate = self;
  [self presentViewController:composeController animated:YES completion:nil];  
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
  
  // Save colage
  RMCollage *collage = composeController.collage;
  
  // Send image
  [[RACObserve(composeController, collageImage)
    filter:^BOOL(UIImage *collageImage) {
      return collageImage != nil;
    }]
   subscribeNext:^(UIImage *collageImage) {
     dispatch_async(dispatch_get_main_queue(), ^{
       
       switch (composeController.shareType) {
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
                                                                 message:@"Please configure Mail account to be able to send emails.\n\nWould you like to save collage to Camera Roll?"
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
       
     });
   }];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Mail Compose Controller Delegate

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
  switch (result) {
    case MFMailComposeResultSent:
    case MFMailComposeResultSaved:
    {
      break;
    }
    case MFMailComposeResultFailed:
    case MFMailComposeResultCancelled:
    default:
      break;
  }
}

@end
