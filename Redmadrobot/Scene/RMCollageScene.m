//
//  RMCollageScene.m
//  Redmadrobot
//
//  Created by Dmitry Shashlov on 11/19/14.
//  Copyright (c) 2014 Dmitry Shashlov. All rights reserved.
//

#import "RMCollageScene.h"

static CGSize kCollageSize = { 288.0f , 288.0f };

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
- (id)initWithCollage:(RMCollage *)collage size:(CGSize)size
{
  self = [super initWithSize:size];
  if (self)
  {
    _collage = collage;
    self.backgroundColor = [UIColor whiteColor];
    
    // Perimeter node
    _perimeterNode = [SKShapeNode shapeNodeWithRect:CGRectMake(0.0f, 0.0f, kCollageSize.width, kCollageSize.height)];
    _perimeterNode.position = CGPointMake((size.width - kCollageSize.width) / 2, (size.height - kCollageSize.height) / 2);
    [self addChild:_perimeterNode];
    
    // Line nodes
    NSMutableArray *lines = [[NSMutableArray alloc] initWithObjects:_perimeterNode, nil];
    for (int i = 1; i < collage.size.intValue; i++) {
      CGFloat gridStep = i * (kCollageSize.width / collage.size.intValue);
      CGFloat linePadding = (size.height - kCollageSize.height) / 4;

      // Vertical points
      CGPoint verticalPoints[2];
      verticalPoints[0] = CGPointMake(gridStep, -linePadding);
      verticalPoints[1] = CGPointMake(gridStep, kCollageSize.height + linePadding);
      
      // Horizontal points
      CGPoint horizontalPoints[2];
      horizontalPoints[0] = CGPointMake(-linePadding, gridStep);
      horizontalPoints[1] = CGPointMake(kCollageSize.width + linePadding, gridStep);

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
      pattern[0] = 10.0;
      pattern[1] = 10.0;
      CGPathRef dashed = CGPathCreateCopyByDashingPath(lineNode.path, NULL, 0, pattern, 2);
      lineNode.path = dashed;
    }
  }
  return self;
}

@end
