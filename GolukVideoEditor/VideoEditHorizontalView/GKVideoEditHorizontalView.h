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

- (void)didTouchDownBackground;

- (void)didChangeToState:(GKVideoHorizontalState)state;

- (void)chunkCellDidDeleteAtIndex:(NSInteger)index;

- (void)chunkCellMovedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

- (void)indexOfChunkCellAtCurrentFrame:(NSInteger)index;

@end

@interface GKVideoEditHorizontalView : UIView

@property (nonatomic, weak) id <GKVideoEditHorizontalViewDelegate> delegate;

@property (nonatomic, strong) GKVideoEditHorizontalViewModel * viewModel;

@property (nonatomic, assign, readonly) NSUInteger selectedIndex;

- (void)loadData;
- (void)addChunkCellModel:(GKVideoChunkCellModel *)cellModel;
- (void)removeSelectedCell;
- (void)divideCellAtCurrentFrame;
- (void)updateCurrentFrameToTimeInterval:(NSTimeInterval)timeInterval;
- (void)updateCurrentFrameToTimeInterval:(NSTimeInterval)timeInterval animation:(BOOL)animation;

@end
