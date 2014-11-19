//
//  RMCollageScene.m
//  Redmadrobot
//
//  Created by Dmitry Shashlov on 11/19/14.
//  Copyright (c) 2014 Dmitry Shashlov. All rights reserved.
//

#import "RMCollageScene.h"

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

      // Vertical points
      CGPoint verticalPoints[2];
      verticalPoints[0] = CGPointMake(gridStep, 0.0f);
      verticalPoints[1] = CGPointMake(gridStep, kCollageSize.height);
      
      // Horizontal points
      CGPoint horizontalPoints[2];
      horizontalPoints[0] = CGPointMake(0.0f, gridStep);
      horizontalPoints[1] = CGPointMake(kCollageSize.width, gridStep);

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
  }
  return self;
}

@end
