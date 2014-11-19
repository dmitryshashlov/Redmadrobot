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
      NSMutableArray *hiddenSectors = [[NSMutableArray alloc] init];
      
      // Group nodes
      for (RMCollageGroup *group in _collage.groups) {
        for (RMCollageSector *sector in group.sectors) {
          [hiddenSectors addObject:sector];
        }
        
        SKShapeNode *groupNode = [RMGroupNode nodeWithGroup:group];
        groupNode.strokeColor = [UIColor blackColor];
        groupNode.lineWidth = 1.0f;
        groupNode.fillColor = [self colorForIndexPath:group.originSector.indexPath];
        [_perimeterNode addChild:groupNode];
      }
      
      // Sector nodes
      for (RMCollageSector *sector in _collage.sectors) {
        RMSectorNode *sectorNode = [RMSectorNode nodeWithSector:sector];
        sectorNode.strokeColor = [UIColor blackColor];
        sectorNode.lineWidth = 1.0f;
        sectorNode.fillColor = [self colorForIndexPath:sector.indexPath];
        if ([hiddenSectors containsObject:sector])
          sectorNode.hidden = YES;
        
        [_perimeterNode addChild:sectorNode];
      }
      
      break;
    }
      
    case RMCollageProductionStepPick:
    {
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
  if (_step == RMCollageProductionStepWireframe)
  {
    UITouch *touch = [touches anyObject];
    CGPoint positionInScene = [touch locationInNode:_perimeterNode];
    
    RMSectorNode *sectorNode = [self sectorNodeAtPoint:positionInScene];
    if (sectorNode)
    {
      self.selectionStartPoint = positionInScene;
      self.selectedIndexPaths = @[sectorNode.sector.indexPath];
      self.originIndexPath = sectorNode.sector.indexPath;
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  if (_step == RMCollageProductionStepWireframe
      && _originIndexPath)
  {
    UITouch *touch = [touches anyObject];
    CGPoint positionInScene = [touch locationInNode:_perimeterNode];
    self.selectedIndexPaths = [self indexPathsForRect:CGRectMake(MIN(_selectionStartPoint.x, positionInScene.x),
                                                                 MIN(_selectionStartPoint.y, positionInScene.y),
                                                                 fabs(_selectionStartPoint.x - positionInScene.x),
                                                                 fabs(_selectionStartPoint.y - positionInScene.y))];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  if (_step == RMCollageProductionStepWireframe
      && _originIndexPath)
  {
    // Group sectors
    if (self.selectedIndexPaths.count > 1)
      [_collage groupSectorsForIndexPaths:self.selectedIndexPaths originSectorIndexPath:_originIndexPath];

    self.selectionStartPoint = CGPointZero;
    self.selectedIndexPaths = nil;
    self.originIndexPath = nil;
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
    [_colors setObject:color forKey:key];
  }
  
  return color;  
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
