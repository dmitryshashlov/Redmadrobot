//
//  RMCollage.m
//  Redmadrobot
//
//  Created by Dmitry Shashlov on 11/19/14.
//  Copyright (c) 2014 Dmitry Shashlov. All rights reserved.
//

#import "RMCollage.h"

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation RMCollageSector

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Init

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCollage:(RMCollage *)collage media:(InstagramMedia *)media indexPath:(NSIndexPath *)indexPath
{
  self = [super init];
  if (self)
  {
    _collage = collage;
    _media = media;
    _indexPath = indexPath;    
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super init];
  if (self)
  {
    _indexPath = [aDecoder decodeObjectForKey:@"indexPath"];
    _media = [aDecoder decodeObjectForKey:@"media"];
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Encoding

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeObject:_indexPath forKey:@"indexPath"];
  [aCoder encodeObject:_media forKey:@"media"];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Equality

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isEqual:(id)object
{
  if ([object isKindOfClass:[RMCollageSector class]])
  {
    RMCollageSector *sector = (RMCollageSector *)object;
    if (sector.indexPath.row == self.indexPath.row
        && sector.indexPath.section == self.indexPath.section)
      return YES;
  }
  return NO;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface RMCollageGroup()
@property (nonatomic, readwrite) RMCollageSector *originSector;
@end

@implementation RMCollageGroup

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Init

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithSectors:(NSArray *)sectors
{
  self = [super init];
  if (self)
  {
    _sectors = sectors;    
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addSector:(RMCollageSector *)sector
{
  NSMutableArray *sectorsMutable = [[NSMutableArray alloc] initWithArray:_sectors];
  if (![sectorsMutable containsObject:sector])
    [sectorsMutable addObject:sector];
  _sectors = [NSArray arrayWithArray:sectorsMutable];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeSector:(RMCollageSector *)sector
{
  NSMutableArray *sectorsMutable = [[NSMutableArray alloc] initWithArray:_sectors];
  if ([sectorsMutable containsObject:sector])
    [sectorsMutable removeObject:sector];
  _sectors = [NSArray arrayWithArray:sectorsMutable];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation RMCollage

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Init

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithSize:(NSNumber *)size
{
  self = [super init];
  if (self)
  {
    _size = size;
    
    // Fill collage with empty sectors
    NSMutableArray *sectorsMutable = [[NSMutableArray alloc] init];
    for (int i = 0; i < size.intValue; i++) {
      for (int n = 0; n < size.intValue; n++) {
        [sectorsMutable addObject:[[RMCollageSector alloc] initWithCollage:self
                                                                     media:nil
                                                                 indexPath:[NSIndexPath indexPathForRow:n inSection:i]]];
      }
    }
    _sectors = [NSArray arrayWithArray:sectorsMutable];
    
    // Create single-sector groups
    NSMutableArray *groupsMutable = [[NSMutableArray alloc] init];
    for (RMCollageSector *sector in _sectors) {
      RMCollageGroup *group = [[RMCollageGroup alloc] initWithSectors:@[sector]];
      group.originSector = sector;
      [groupsMutable addObject:group];
    }
    _groups = [[NSMutableArray alloc] initWithArray:groupsMutable];    
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super init];
  if (self)
  {
    _size = [aDecoder decodeObjectForKey:@"size"];
    _sectors = [aDecoder decodeObjectForKey:@"sectors"];
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Encoding

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeObject:_size forKey:@"size"];
  [aCoder encodeObject:_sectors forKey:@"sectors"];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (RMCollageSector *)sectorForIndexPath:(NSIndexPath *)indexPath
{
  for (RMCollageSector *sector in _sectors) {
    if (sector.indexPath.row == indexPath.row && sector.indexPath.section == indexPath.section)
      return sector;
  }
  return nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Grouping

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)groupSectorsForIndexPaths:(NSArray *)sectorIndexPaths originSectorIndexPath:(NSIndexPath *)originIndexPath
{
  NSArray *sectors = [sectorIndexPaths.rac_sequence map:^id(NSIndexPath *indexPath) {
    return [self sectorForIndexPath:indexPath];
  }].array;
  
  NSMutableArray *groupsMutable = [self mutableArrayValueForKeyPath:@"groups"];
  
  // 1. Remove this sectors from other groups
  for (RMCollageGroup *group in [NSArray arrayWithArray:_groups]) {
    for (RMCollageSector *sector in sectors) {
      [group removeSector:sector];
    }
    
    if (!group.sectors.count)
      [groupsMutable removeObject:group];
  }
  
  // 2. Create new group
  RMCollageGroup *group = [[RMCollageGroup alloc] initWithSectors:sectors];
  group.originSector = [self sectorForIndexPath:originIndexPath];
  [groupsMutable addObject:group];
}

@end
