//
//  Kiwi.m
//  Redmadrobot
//
//  Created by Dmitry Shashlov on 11/21/14.
//  Copyright (c) 2014 Dmitry Shashlov. All rights reserved.
//

#import "Kiwi.h"
#import <UIKit/UIKit.h>
#import "RMCollage.h"

SPEC_BEGIN(RMCollageSpecs)

describe(@"created", ^{
  
  context(@"with size of 3",^{
    
    __block RMCollage *collage = nil;
    
    beforeAll(^{
      collage = [[RMCollage alloc] initWithSize:@3];
    });
    
    afterAll(^{
      collage = nil;
    });
    
    it(@"contains 9 sectors", ^{
      [[collage.sectors should] haveCountOf:9];
    });
    
    it(@"contains 9 groups", ^{
      [[collage.groups should] haveCountOf:9];
    });
    
    it(@"each group contains 1 sector", ^{
      for (RMCollageGroup *group in [collage groups])
      {
        [[group.sectors should] haveCountOf:1];
      }
    });
    
    it(@"number or sections equal to size of collage", ^{
      [[theValue([[collage.sectors valueForKeyPath:@"@max.indexPath.section"] intValue]) should] equal:theValue(2)];
    });
    
    it(@"number or rows equal to size of collage", ^{
      [[theValue([[collage.sectors valueForKeyPath:@"@max.indexPath.row"] intValue]) should] equal:theValue(2)];
    });
    
    it(@"contains same 9 groups after clear", ^{
      [collage clearGroups];
      [[collage.groups should] haveCountOf:9];
    });
    
    context(@"after grouping two sectors", ^{

      it(@"contains 8 groups after grouping 2 sectors", ^{
        [collage groupSectorsForIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0],
                                             [NSIndexPath indexPathForRow:1 inSection:0]]
                     originSectorIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [[collage.groups should] haveCountOf:8];
      });
      
      it(@"1 group contains 2 sectors, other - 1", ^{
        int numberOfGroupsContainingOneSector = 0;
        int numberOfGroupsContainingTwoSectors = 0;
        for (RMCollageGroup *group in collage.groups)
        {
          if (group.sectors.count == 1)
            numberOfGroupsContainingOneSector++;
          else if (group.sectors.count == 2)
            numberOfGroupsContainingTwoSectors++;
        }
        [[theValue(numberOfGroupsContainingTwoSectors) should] equal:theValue(1)];
        [[theValue(numberOfGroupsContainingOneSector) should] equal:theValue(7)];
      });
    });
    
    it(@"contains 1 group after grouping all sectors", ^{
      NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
      for (int i = 0 ; i < collage.size.intValue ; i++)
      {
        for (int n = 0 ; n < collage.size.intValue ; n++)
        {
          [indexPaths addObject:[NSIndexPath indexPathForRow:n inSection:i]];
        }
      }
      [collage groupSectorsForIndexPaths:indexPaths originSectorIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
      [[collage.groups should] haveCountOf:1];
    });
    
  });
  
});

SPEC_END
