//
//  RMCollageScene.m
//  Redmadrobot
//
//  Created by Dmitry Shashlov on 11/19/14.
//  Copyright (c) 2014 Dmitry Shashlov. All rights reserved.
//

#import "RMCollageScene.h"

#import "RMSectorNode.h"
#import "RMGroupNode.h"

static CGFloat kDashLength = 10.0f;
CGSize kCollageSize = { 288.0f , 288.0f };

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface RMCollageScene()
@property (nonatomic) SKShapeNode *perimeterNode;
@property (nonatomic) NSArray *selectedIndexPaths;
@property (nonatomic) CGPoint selectionStartPoint;
@property (nonatomic) SKShapeNode *selectionNode;
@property (nonatomic) NSMutableDictionary *colors;
@property (nonatomic) NSIndexPath *originIndexPath;
@property (nonatomic, readwrite) RMCollageGroup *selectedGroup;
@property (nonatomic) NSMutableArray *groupDisposables;
@end

@implementation RMCollageScene

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Init

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCollage:(RMCollage *)collage productionStep:(RMCollageProductionStep)step size:(CGSize)size
{
  self = [super initWithSize:size];
  if (self)
  {
    _step = step;
    _collage = collage;
    self.backgroundColor = [UIColor whiteColor];
    _colors = [[NSMutableDictionary alloc] init];
    _groupDisposables = [[NSMutableArray alloc] init];
    
    CGRect perimeterRect = CGRectMake(0.0f, 0.0f, kCollageSize.width, kCollageSize.height);
    
    // Perimeter node
    _perimeterNode = [SKShapeNode shapeNodeWithRect:perimeterRect];
    _perimeterNode.position = CGPointMake((size.width - kCollageSize.width) / 2, (size.height - kCollageSize.height) / 2);
    _perimeterNode.strokeColor = [UIColor blackColor];
    _perimeterNode.lineWidth = 1.0f;
    [self addChild:_perimeterNode];
        
    // Observe selected index paths
    [[RACObserve(self, selectedIndexPaths) distinctUntilChanged]
     subscribeNext:^(NSArray *selectedIndexPaths) {
       [_selectionNode removeFromParent];
       if (selectedIndexPaths.count)
       {
         CGRect rect = CGRectZero;
         for (NSIndexPath *indexPath in selectedIndexPaths) {
           CGRect desiredRect = [[self class] rectForIndexPath:indexPath
                                               withCollageSize:_collage.size.intValue];
           if (rect.origin.x == 0 && rect.origin.y == 0 && rect.size.width == 0 && rect.size.height == 0)
             rect = desiredRect;
           else
             rect = CGRectUnion(rect, desiredRect);
         }
         rect = CGRectOffset(rect, _perimeterNode.position.x, _perimeterNode.position.y);
         
         _selectionNode = [SKShapeNode shapeNodeWithRect:rect];
         _selectionNode.strokeColor = [UIColor redColor];
         _selectionNode.lineWidth = 2.0f;
         [self addChild:_selectionNode];
       }
     }];
    
    // Observe group changing
    [RACObserve(self.collage, groups)
     subscribeNext:^(id x) {
       [self configureSceneForStep:_step];
     }];
    
    // Observe group selecting
    [[RACObserve(self, selectedGroup) distinctUntilChanged]
     subscribeNext:^(RMCollageGroup *group) {
       [self configureSceneForStep:_step];
     }];
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Configure

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)configureSceneForStep:(RMCollageProductionStep)step
{
  [_perimeterNode removeAllChildren];
  
  void (^bootstrapSectorsBlock)(void) = ^{
    for (RMCollageSector *sector in _collage.sectors) {
      RMSectorNode *sectorNode = [RMSectorNode nodeWithSector:sector];
      sectorNode.strokeColor = [UIColor blackColor];
      sectorNode.lineWidth = 1.0f;
      sectorNode.fillColor = [self colorForIndexPath:sector.indexPath];
      sectorNode.hidden = YES;
      
      [_perimeterNode addChild:sectorNode];
    }
  };
  
  void (^bootstrapGroupsBlock)(void(^)(RMCollageGroup *group, SKShapeNode *groupNode)) = ^(void(^groupNodeBlock)(RMCollageGroup *, SKShapeNode *)){
    for (RMCollageGroup *group in _collage.groups) {
      SKShapeNode *groupNode = [RMGroupNode nodeWithGroup:group];
      groupNode.strokeColor = [UIColor blackColor];
      groupNode.lineWidth = 1.0f;
      if (group == _selectedGroup)
        groupNode.fillColor = [UIColor redColor];
      else
        groupNode.fillColor = [self colorForIndexPath:group.originSector.indexPath];
      
      if (groupNodeBlock)
        groupNodeBlock(group, groupNode);
      
      [_perimeterNode addChild:groupNode];
    }
  };
  
  // Configure nodes
  switch (step) {
    case RMCollageProductionStepGrid:
    {
      // Line nodes
      NSMutableArray *lines = [[NSMutableArray alloc] init];
      for (int i = 1; i < _collage.size.intValue; i++) {
        CGFloat gridStep = kCollageSize.width / _collage.size.intValue;
        
        // Vertical points
        CGPoint verticalPoints[2];
        verticalPoints[0] = CGPointMake(i * gridStep, 0.0f);
        verticalPoints[1] = CGPointMake(i * gridStep, kCollageSize.height);
        
        // Horizontal points
        CGPoint horizontalPoints[2];
        horizontalPoints[0] = CGPointMake(0.0f, i * gridStep);
        horizontalPoints[1] = CGPointMake(kCollageSize.width, i * gridStep);
        
        SKShapeNode *verticalLine = [SKShapeNode shapeNodeWithPoints:verticalPoints count:sizeof(verticalPoints) / sizeof(CGPoint)];
        SKShapeNode *horizontalLine = [SKShapeNode shapeNodeWithPoints:horizontalPoints count:sizeof(horizontalPoints) / sizeof(CGPoint)];
        [lines addObject:verticalLine];
        [lines addObject:horizontalLine];
      }
      
      // Apply params
      for (SKShapeNode *lineNode in lines) {
        lineNode.strokeColor = [UIColor blackColor];
        lineNode.lineWidth = 1.0f;
        [_perimeterNode addChild:lineNode];
        
        // Dash
        CGFloat pattern[2];
        pattern[0] = kDashLength;
        pattern[1] = kDashLength;
        CGFloat phase = arc4random_uniform(kDashLength * sizeof(pattern) / sizeof(CGFloat));
        CGPathRef dashed = CGPathCreateCopyByDashingPath(lineNode.path, NULL, phase, pattern, 2);
        lineNode.path = dashed;
      }
      break;
    }
      
    case RMCollageProductionStepWireframe:
    {
      
      // Group nodes
      bootstrapGroupsBlock(nil);
      
      // Sector nodes
      bootstrapSectorsBlock();
      
      break;
    }
      
    case RMCollageProductionStepPick:
    {
      // Clear group disposables
      for (RACDisposable *disposable in [NSArray arrayWithArray:_groupDisposables]) {
        [disposable dispose];
        [_groupDisposables removeObject:disposable];
      }
      
      // Group nodes
      void (^reactiveBlock)(RMCollageGroup *, SKShapeNode *) = ^(RMCollageGroup *group, SKShapeNode *groupNode){
          RACDisposable *groupDisposable = [[[RACObserve(group, media) distinctUntilChanged]
                                             filter:^BOOL(InstagramMedia *media) {
                                               return media != nil;
                                             }]
                                            subscribeNext:^(InstagramMedia *media) {
                                              [[NSData rac_readContentsOfURL:group.media.lowResolutionImageURL
                                                                     options:0
                                                                   scheduler:[RACScheduler schedulerWithPriority:RACSchedulerPriorityBackground]]
                                               subscribeNext:^(NSData *data) {
                                                 SKTexture *texture = [SKTexture textureWithImage:[UIImage imageWithData:data]];
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                   CGRect groupRect = [self rectForGroup:group];
                                                   CGSize imageNodeSize = CGSizeMake(MAX(groupRect.size.width, groupRect.size.height),
                                                                                     MAX(groupRect.size.width, groupRect.size.height));
                                                   
                                                   // Image node
                                                   SKSpriteNode *imageNode = [SKSpriteNode spriteNodeWithTexture:texture
                                                                                                            size:imageNodeSize];
                                                   imageNode.position = CGPointMake(groupRect.origin.x + groupRect.size.width / 2,
                                                                                    groupRect.origin.y + groupRect.size.height / 2);
                                                   
                                                   // Mask node
                                                   SKSpriteNode *maskNode = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:groupRect.size];
                                                   maskNode.position = imageNode.position;
                                                   
                                                   // Crop node
                                                   SKCropNode *cropNode = [SKCropNode node];
                                                   [cropNode addChild:imageNode];
                                                   [cropNode setMaskNode:maskNode];
                                                   [groupNode addChild:cropNode];
                                                 });
                                               }
                                               error:^(NSError *error) {
                                                 NSLog(@"%@", error.localizedDescription);
                                               }];
                                            }];
          [_groupDisposables addObject:groupDisposable];
      };
      bootstrapGroupsBlock(reactiveBlock);
      
      // Sector nodes
      bootstrapSectorsBlock();

      break;
    }
      
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Touches

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = [touches anyObject];
  CGPoint positionInScene = [touch locationInNode:_perimeterNode];
  RMSectorNode *sectorNode = [self sectorNodeAtPoint:positionInScene];
  if (sectorNode)
  {
    switch (_step) {
      case RMCollageProductionStepWireframe:
      {
        self.selectionStartPoint = positionInScene;
        self.selectedIndexPaths = @[sectorNode.sector.indexPath];
        self.originIndexPath = sectorNode.sector.indexPath;
        break;
      }
        
      case RMCollageProductionStepPick:
      {
        self.originIndexPath = sectorNode.sector.indexPath;
        break;
      }
        
      case RMCollageProductionStepGrid:
        break;
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = [touches anyObject];
  CGPoint positionInScene = [touch locationInNode:_perimeterNode];
  
  if (_originIndexPath)
  {
    switch (_step) {
      case RMCollageProductionStepWireframe:
      {
        self.selectedIndexPaths = [self indexPathsForRect:CGRectMake(MIN(_selectionStartPoint.x, positionInScene.x),
                                                                     MIN(_selectionStartPoint.y, positionInScene.y),
                                                                     fabs(_selectionStartPoint.x - positionInScene.x),
                                                                     fabs(_selectionStartPoint.y - positionInScene.y))];
        break;
      }
        
      case RMCollageProductionStepPick:
      case RMCollageProductionStepGrid:
        break;
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = [touches anyObject];
  CGPoint positionInScene = [touch locationInNode:_perimeterNode];
  if (_originIndexPath)
  {
    switch (_step) {
      case RMCollageProductionStepWireframe:
      {
        // Group sectors
        if (self.selectedIndexPaths.count)
          [_collage groupSectorsForIndexPaths:self.selectedIndexPaths originSectorIndexPath:_originIndexPath];
        
        self.selectionStartPoint = CGPointZero;
        self.selectedIndexPaths = nil;
        self.originIndexPath = nil;
        break;
      }

      case RMCollageProductionStepPick:
      {
        RMSectorNode *sectorNode = [self sectorNodeAtPoint:positionInScene];
        if (sectorNode.sector.indexPath.row == _originIndexPath.row
            && sectorNode.sector.indexPath.section == _originIndexPath.section)
          self.selectedGroup = [_collage groupContainingSector:sectorNode.sector];
        self.originIndexPath = nil;
        break;
      }
        
      case RMCollageProductionStepGrid:
        break;
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (RMSectorNode *)sectorNodeAtPoint:(CGPoint)point
{
  for (SKNode *node in [_perimeterNode nodesAtPoint:point]) {
    if ([node isKindOfClass:[RMSectorNode class]])
      return (RMSectorNode *)node;
  }
  return nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray *)indexPathsForRect:(CGRect)frame
{
  SKNode *node1 = [self sectorNodeAtPoint:CGPointMake(frame.origin.x, frame.origin.y)];
  SKNode *node2 = [self sectorNodeAtPoint:CGPointMake(frame.origin.x + frame.size.width, frame.origin.y)];
  SKNode *node3 = [self sectorNodeAtPoint:CGPointMake(frame.origin.x + frame.size.width, frame.origin.y + frame.size.height)];
  SKNode *node4 = [self sectorNodeAtPoint:CGPointMake(frame.origin.x, frame.origin.y + frame.size.height)];
  
  NSArray *nodes = @[node1, node2, node3, node4];
  
  NSNumber *minSection = [nodes valueForKeyPath:@"@min.sector.indexPath.section"];
  NSNumber *maxSection = [nodes valueForKeyPath:@"@max.sector.indexPath.section"];
  NSNumber *minRow = [nodes valueForKeyPath:@"@min.sector.indexPath.row"];
  NSNumber *maxRow = [nodes valueForKeyPath:@"@max.sector.indexPath.row"];
  
  NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
  for (int i = minSection.intValue ; i <= maxSection.intValue ; i++) {
    for (int n = minRow.intValue ; n <= maxRow.intValue ; n++) {
      NSIndexPath *indexPath = [NSIndexPath indexPathForRow:n inSection:i];
      [indexPaths addObject:indexPath];
    }
  }
  
  NSLog(@"[%d] - min section: %d, max section: %d, min row: %d, max row: %d", indexPaths.count, minSection.intValue, maxSection.intValue, minRow.intValue, maxRow.intValue);

  return [NSArray arrayWithArray:indexPaths];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor *)colorForIndexPath:(NSIndexPath *)indexPath
{
  NSString *key = [NSString stringWithFormat:@"%d:%d", indexPath.section, indexPath.row];
  UIColor *color = [_colors objectForKey:key];
  if (!color)
  {
    color = [UIColor colorWithRed:arc4random_uniform(255.0f) / 255.0f
                            green:arc4random_uniform(255.0f) / 255.0f
                             blue:arc4random_uniform(255.0f) / 255.0f
                            alpha:0.5f];
    color = [UIColor whiteColor];
    [_colors setObject:color forKey:key];
  }
  
  return color;  
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)rectForGroup:(RMCollageGroup *)group
{
  CGRect rect = CGRectZero;
  for (RMCollageSector *sector in group.sectors) {
    CGRect sectorRect = [[self class] rectForIndexPath:sector.indexPath
                                       withCollageSize:sector.collage.size.intValue];
    if (rect.origin.x == 0 && rect.origin.y == 0 && rect.size.width == 0 && rect.size.height == 0)
      rect = sectorRect;
    else
      rect = CGRectUnion(rect, sectorRect);
  }
  
  return rect;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Class

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGRect)rectForIndexPath:(NSIndexPath *)indexPath withCollageSize:(NSUInteger)collageSize
{
  CGFloat gridStep = kCollageSize.width / collageSize;
  return CGRectMake(indexPath.row * gridStep,
                    indexPath.section * gridStep,
                    gridStep,
                    gridStep);
}

@end
