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

/**
 *  回调当前 CurrentFrame 所在的时间.
 *  当 CurrentFrame 所在的帧移动的时候， 也会改变当前的时间
 */
- (void)timeIntervalAtCurrentFrame:(CGFloat)timeInterval;

/**
 *  回调当前 CurrentFrame 所在的片段的 index
 */
- (void)chunkCellOfCurrentFrameChangedAtIndex:(NSInteger)index;

/**
 *  点击了添加片段
 */
- (void)didTouchAddChunk;

/**
 *  滚动区域开始用户启动的滚动
 */
- (void)scrollAreaBeganScrollByManual;

/**
 *  点击了空白背景区域
 */
- (void)didTouchDownBackground;

/**
 *  当前的状态改变
 */
- (void)didChangeToState:(GKVideoHorizontalState)state;

/**
 *  当编辑的片段有变化， 并且在退出编辑状态的时候，回调该变化状态
 *  index:      编辑的片段的index
 *  beginTime:  编辑后的起始时间
 *  endTime:    编辑后的结束时间
 */
- (void)didEditChunkCellAtIndex:(NSInteger)index
                      beginTime:(NSTimeInterval)beginTime
                        endTime:(NSTimeInterval)endTime;

/**
 *  回调当前 CurrentFrame 能否执行 split
 */
- (void)couldSplitAtCurrentFrame:(BOOL)couldSplit;

/**
 *  切割片段的回调
 *  index:      切分的片段的index
 *  time:       切分的时间点
 */
- (void)didSplitAtIndex:(NSInteger)index atTime:(NSTimeInterval)time;

/**
 *  删除片段
 *  index:      删除的片段的index
 */
- (void)chunkCellDidDeleteAtIndex:(NSInteger)index;

/**
 *  移动片段， 将片段从 fromIndex 移动到 toIndex。
 *  例如： 1-2-3-4-5的一个片段
 *  将2移动到4，结果就是1-3-4-2-5
 */
- (void)chunkCellMovedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

@end

@interface GKVideoEditHorizontalView : UIView

@property (nonatomic, weak            ) id <GKVideoEditHorizontalViewDelegate>  delegate;
@property (nonatomic, strong          ) GKVideoEditHorizontalViewModel          * viewModel;
@property (nonatomic, assign, readonly) GKVideoHorizontalState                  state;

/**
 *  当前所处于编辑状态的片段的 index
 */
@property (nonatomic, assign, readonly) NSUInteger selectedIndex;

/**
 *  加载数据
 */
- (void)loadData;

/**
 *  添加一个片段
 */
- (void)addChunkCellModel:(GKVideoChunkCellModel *)cellModel;

/**
 *  删除当前处于编辑状态的片段
 */
- (void)removeSelectedCell;

/**
 *  在当前 CurrentFrame 所处的片段， 拆分此片段
 */
- (void)splitCellAtCurrentFrame;

/**
 *  更新到 CurrentFrame 到 timeInterval 的时间点
 */
- (void)updateCurrentFrameToTimeInterval:(NSTimeInterval)timeInterval;

/**
 *  更新状态到正常状态
 */
- (void)resetToNormalState;

@end
