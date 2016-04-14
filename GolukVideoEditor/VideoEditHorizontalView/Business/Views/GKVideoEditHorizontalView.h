//
//  GKVideoEditHorizontalView.h
//  GolukVideoEditor
//
//  Created by apple on 16/4/12.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKVideoHorizontalScrollView.h"
#import "GKVideoEditHorizontalViewModel.h"

@protocol GKVideoEditHorizontalViewDelegate <NSObject>

@optional

- (void)timeIntervalOfCurrentFrame:(CGFloat)timeInterval;

- (void)didTouchAddChunk;

- (void)chunkCellDeletedAtIndex:(NSInteger)index;

- (void)chunkCellMovedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

@end

@interface GKVideoEditHorizontalView : UIView

@property (nonatomic, weak) id <GKVideoEditHorizontalViewDelegate> delegate;

@property (nonatomic, strong) GKVideoEditHorizontalViewModel * viewModel;

- (void)loadData;
- (void)addChunkCellModel:(GKVideoChunkCellModel *)cellModel;
- (void)removeSelectedCell;
- (void)divideCellAtCurrentFrame;

// TO DELETE
- (void)updateTemp;
- (void)updateTempAnimation;

@end
