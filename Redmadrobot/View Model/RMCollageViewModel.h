//
//  RMCollageViewModel.h
//  Redmadrobot
//
//  Created by Dmitry Shashlov on 11/19/14.
//  Copyright (c) 2014 Dmitry Shashlov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "RMCollage.h"
#import "RMCollageScene.h"

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface RMCollageViewModel : NSObject

- (id)initWithCollage:(RMCollage *)collage;
- (RMCollageScene *)sceneForProductionStep:(RMCollageProductionStep)step withSize:(CGSize)size;
- (void)buildCollageImageWithSize:(CGSize)size completionBlock:(void(^)(UIImage *))completionBlock;

@property (nonatomic, readonly) RMCollage *collage;

@end
