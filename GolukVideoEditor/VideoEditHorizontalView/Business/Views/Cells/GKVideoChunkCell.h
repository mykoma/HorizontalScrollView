//
//  GKVideoChunkCell.h
//  GolukVideoEditor
//
//  Created by apple on 16/4/10.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKHorizontalCell.h"
#import "GKVideoChunkCellModel.h"

@class GKVideoFenceCell;

@interface GKVideoChunkCell : GKHorizontalCell

@property (nonatomic, weak  ) GKVideoFenceCell * leftFenceCell;
@property (nonatomic, weak  ) GKVideoFenceCell * rightFenceCell;

@property (nonatomic, strong) GKVideoChunkCellModel * cellModel;

@property (nonatomic, copy) void (^touchDown)();
@property (nonatomic, copy) void (^visibleChanged)();

+ (CGFloat)widthForModel:(GKVideoChunkCellModel *)cellModel;

+ (CGFloat)widthOfOneSecond;

/**
 *  offset in current cell.
 */
- (NSTimeInterval)timeIntervalOfVisibleOffset:(CGFloat)offset;

@end
