//
//  RMCollage.h
//  Redmadrobot
//
//  Created by Dmitry Shashlov on 11/19/14.
//  Copyright (c) 2014 Dmitry Shashlov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <InstagramKit/InstagramMedia.h>

typedef enum {
  RMCollageProductionStepGrid = 1,
  RMCollageProductionStepWireframe = 2,
  RMCollageProductionStepPick = 3
} RMCollageProductionStep;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@class RMCollage;

@interface RMCollageSector : NSObject<NSCoding>

@property (nonatomic, readonly) RMCollage *collage;
@property (nonatomic, readonly) InstagramMedia *media;
@property (nonatomic, readonly) NSIndexPath *indexPath;

- (id)initWithCollage:(RMCollage *)collage media:(InstagramMedia *)media indexPath:(NSIndexPath *)indexPath;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface RMCollageGroup

@property (nonatomic, readonly) NSArray *sectors;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface RMCollage : NSObject<NSCoding>

@property (nonatomic, readonly) NSNumber *size;
@property (nonatomic, readonly) NSArray *sectors;
@property (nonatomic, readonly) NSArray *groups;

- (id)initWithSize:(NSNumber *)size;

@end
