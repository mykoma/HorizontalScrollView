//
//  GKVideoChunkCell.h
//  GolukVideoEditor
//
//  Created by apple on 16/4/10.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKHorizontalCell.h"
#import "GKVideoChunkCellModel.h"

extern NSString * GK_VIDEO_CHUNK_CELL_NOTIFICATION_BECOME_EDIT;

typedef NS_ENUM(NSUInteger, GKVideoChunkCellState)
{
    GKVideoChunkCellStateNormal = 0,
    GKVideoChunkCellStateEdit
};

@class GKVideoFenceCell;
@class GKVideoChunkCell;

@protocol GKVideoChunkCellDelegate <NSObject>

@optional

- (void)chunkCell:(GKVideoChunkCell *)chunkCell leftPositionChangedInSuperView:(CGFloat)offset;

- (void)chunkCell:(GKVideoChunkCell *)chunkCell rightPositionChangedInSuperView:(CGFloat)offset;

- (void)didFinishEditForChunkCell:(GKVideoChunkCell *)chunkCell;

- (void)didChangeToEditWithTouchDownForChunkCell:(GKVideoChunkCell *)chunkCell;

@end

@interface GKVideoChunkCell : GKHorizontalCell

@property (nonatomic, weak  ) id <GKVideoChunkCellDelegate> chunkCellDelegate;

@property (nonatomic, weak  ) GKVideoFenceCell * leftFenceCell;
@property (nonatomic, weak  ) GKVideoFenceCell * rightFenceCell;

@property (nonatomic, strong) GKVideoChunkCellModel * cellModel;

@property (nonatomic, copy) void (^touchDown)();
@property (nonatomic, copy) void (^stateChangedToEdit)();
@property (nonatomic, copy) void (^visibleChanged)();

+ (NSTimeInterval)durationOfWidth:(CGFloat)offset;

+ (CGFloat)widthForModel:(GKVideoChunkCellModel *)cellModel;

+ (CGFloat)widthOfOneSecond;

+ (void)resignEditState;

- (void)becomeToEditState;


@end
