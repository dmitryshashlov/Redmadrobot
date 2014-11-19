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
    
    // Perimeter node
    _perimeterNode = [SKShapeNode shapeNodeWithRect:CGRectMake(0.0f, 0.0f, kCollageSize.width, kCollageSize.height)];
    _perimeterNode.position = CGPointMake((size.width - kCollageSize.width) / 2, (size.height - kCollageSize.height) / 2);
    _perimeterNode.strokeColor = [UIColor blackColor];
    _perimeterNode.lineWidth = 1.0f;
    [self addChild:_perimeterNode];
    
    // Configure
    [self configureSceneForStep:_step];
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Configure

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)configureSceneForStep:(RMCollageProductionStep)step
{
  // Configure nodes
  switch (step) {
    case RMCollageProductionStepGrid:
    {
      // Line nodes
      NSMutableArray *lines = [[NSMutableArray alloc] initWithObjects:_perimeterNode, nil];
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
        
        if (lineNode != _perimeterNode)
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
      NSMutableArray *sectors = [[NSMutableArray alloc] initWithArray:_collage.sectors];
      
      // Group nodes
      for (RMCollageGroup *group in _collage.groups) {
        for (RMCollageSector *sector in group.sectors) {
          [sectors removeObject:sector];
        }
        
        SKShapeNode *groupNode = [[RMGroupNode alloc] initWithCollageGroup:group];
        groupNode.strokeColor = [UIColor blackColor];
        groupNode.lineWidth = 1.0f;
        [_perimeterNode addChild:groupNode];
      }
      
      // Sector nodes
      for (RMCollageSector *sector in [NSArray arrayWithArray:sectors]) {
        RMSectorNode *sectorNode = [[RMSectorNode alloc] initWithSector:sector];
        sectorNode.strokeColor = [UIColor blackColor];
        sectorNode.lineWidth = 1.0f;
        sectorNode.fillColor = [UIColor colorWithRed:arc4random_uniform(255.0f) / 255.0f
                                               green:arc4random_uniform(255.0f) / 255.0f
                                                blue:arc4random_uniform(255.0f) / 255.0f
                                               alpha:0.5f];
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
  UITouch *touch = [touches anyObject];
  CGPoint positionInScene = [touch locationInNode:self];
  SKShapeNode *node = (SKShapeNode *)[self nodeAtPoint:positionInScene];
  
  // Log
  if ([node isKindOfClass:[RMSectorNode class]])
  {
    RMSectorNode *sectorNode = (RMSectorNode *)node;
    NSIndexPath *indexPath = sectorNode.sector.indexPath;
    NSLog(@"Node (%@) touched: %d, %d", NSStringFromClass([node class]), indexPath.section, indexPath.row);
  }
  else if ([node isKindOfClass:[RMGroupNode class]])
  {
    RMGroupNode *groupNode = (RMGroupNode *)node;
    //
  }
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
