//
//  RMCollageScene.h
//  Redmadrobot
//
//  Created by Dmitry Shashlov on 11/19/14.
//  Copyright (c) 2014 Dmitry Shashlov. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "RMCollage.h"

extern CGSize kCollageSize;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface RMCollageScene : SKScene

- (id)initWithCollage:(RMCollage *)collage productionStep:(RMCollageProductionStep)step size:(CGSize)size;
+ (CGRect)rectForIndexPath:(NSIndexPath *)indexPath withCollageSize:(NSUInteger)collageSize;

@property (nonatomic, readonly) RMCollage *collage;
@property (nonatomic, readonly) RMCollageProductionStep step;
@property (nonatomic, readonly) RMCollageGroup *selectedGroup;

@end
