//
//  RMCollage.m
//  Redmadrobot
//
//  Created by Dmitry Shashlov on 11/19/14.
//  Copyright (c) 2014 Dmitry Shashlov. All rights reserved.
//

#import "RMCollage.h"

static NSString * const kUDKeyCollages = @"collages";

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface RMCollageSector()
@property (nonatomic, readwrite) InstagramMedia *media;
@end

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
    [self bootstrapGroups];
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super init];
  if (self)
  {
    _previewImage = [UIImage imageWithData:[aDecoder decodeObjectForKey:@"previewImage"]];
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Encoding

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeObject:UIImageJPEGRepresentation(_previewImage, 0.9f) forKey:@"previewImage"];
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
#pragma mark - Private

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)bootstrapGroups
{
  NSMutableArray *groupsMutable = [self mutableArrayValueForKeyPath:@"groups"];
  for (RMCollageSector *sector in _sectors) {
    RMCollageGroup *group = [[RMCollageGroup alloc] initWithSectors:@[sector]];
    group.originSector = sector;
    [groupsMutable addObject:group];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Grouping

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)groupSectorsForIndexPaths:(NSArray *)sectorIndexPaths originSectorIndexPath:(NSIndexPath *)originIndexPath
{
  @weakify(self);
  NSArray *sectors = [sectorIndexPaths.rac_sequence map:^id(NSIndexPath *indexPath) {
    @strongify(self);
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

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)clearGroups
{
  NSMutableArray *groupsMutable = [self mutableArrayValueForKeyPath:@"groups"];
  [groupsMutable removeAllObjects];
  [self bootstrapGroups];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)clearGroupsMedia
{
  for (RMCollageGroup *group in _groups) {
    group.media = nil;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (RMCollageGroup *)groupContainingSector:(RMCollageSector *)sector
{
  for (RMCollageGroup *group in _groups) {
    if ([group.sectors containsObject:sector])
      return group;
  }
  return nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)save
{
  NSMutableArray *collages = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:kUDKeyCollages]];
  [collages addObject:[NSKeyedArchiver archivedDataWithRootObject:self]];
  [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:collages] forKey:kUDKeyCollages];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Class

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSArray *)savedCollages
{
  NSArray *archivedObjects = [[NSUserDefaults standardUserDefaults] objectForKey:kUDKeyCollages];
  return [archivedObjects.rac_sequence map:^id(NSData *unarchivedData) {
    return [NSKeyedUnarchiver unarchiveObjectWithData:unarchivedData];
  }].array;
}

@end
