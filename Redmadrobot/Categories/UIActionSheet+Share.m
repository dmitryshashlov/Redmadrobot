//
//  UIActionSheet+Share.m
//  Redmadrobot
//
//  Created by Dmitry Shashlov on 11/20/14.
//  Copyright (c) 2014 Dmitry Shashlov. All rights reserved.
//

#import "UIActionSheet+Share.h"
#import "RMCollage.h"

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UIActionSheet(Share)

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (UIActionSheet *)shareActionSheetWithBlock:(void (^)(NSNumber *))shareBlock
{
  UIActionSheet *shareSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                          delegate:nil
                                                 cancelButtonTitle:@"Cancel"
                                            destructiveButtonTitle:nil
                                                 otherButtonTitles:@"Save to Camera Roll", @"Send via email", nil];
  [[shareSheet rac_buttonClickedSignal]
   subscribeNext:^(NSNumber *buttonIndex) {
     RMCollageShareType shareType = RMCollageShareTypeUndefined;
     switch (buttonIndex.intValue) {
       case 0:
         shareType = RMCollageShareTypeGallery;
         break;
         
       case 1:
         shareType = RMCollageShareTypeMail;
         break;
     }
     
     if (shareBlock)
       shareBlock([NSNumber numberWithInt:shareType]);
   }];
  
  return shareSheet;
}

@end
