//
//  GKVideoEditScrollView.h
//  GolukVideoEditor
//
//  Created by apple on 16/4/11.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKHorizontalScrollView.h"
#import "GKVideoChunkCell.h"

typedef NS_ENUM(NSUInteger, GKVideoHorizontalState)
{
    GKVideoHorizontalStateNormal = GKVideoChunkCellStateNormal,
    GKVideoHorizontalStateEdit = GKVideoChunkCellStateEdit
};

/*****************************
 *  数据源
 *****************************/
@protocol GKVideoHorizontalScrollDataSource <GKHorizontalScrollDataSource>

@required
/**
 *  根据 itemModel 获取一个 Cell
 */
- (GKHorizontalCell *)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
                          cellForItemModel:(id)itemModel;

@end

/*****************************
 *  布局
 *****************************/
@protocol GKVideoHorizontalScrollViewLayout <GKHorizontalScrollViewLayout>

@required

/**
 *  默认的CurrentFrame 偏移量
 */
- (CGFloat)defaultOffsetOfCurrentFrameOfHorizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView;

/**
 *  根据 itemModel 返回 Size
 */
- (CGSize)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
              sizeForItemModel:(id)itemModel;

@end

/*****************************
 * 事件处理
 *****************************/
@protocol GKVideoHorizontalScrollViewDelegate <GKHorizontalScrollViewDelegate>

@required
/**
 * 分割视频，会返回分割后的 cellModels，交由 Delegate 处理， 再返回回来
 */
- (NSArray *)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
cellModelAfterInterceptDividedModels:(NSArray *)cellModels;
/**
 * 增加视频，会返回增加后的 cellModels，交由 Delegate 处理， 再返回回来
 */
- (NSArray *)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
cellModelAfterInterceptAppendModels:(NSArray *)cellModels;

@optional

/**
 *  回调当前 scrollView 的偏移量的时间点
 */
- (void)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
  timeIntervalOfScrollOffset:(CGFloat)timeInterval;

/**
 *  回调当前删除的片段的 index
 */
- (void)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
   chunkCellDidDeleteAtIndex:(NSInteger)index;

/**
 *   回调 chunkCell 从 fromIndex 移动到了 toIndex
 */
- (void)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
      chunkCellMoveFromIndex:(NSInteger)fromIndex
                     toIndex:(NSInteger)toIndex;

/**
 *  回调当前编辑状态的改变
 */
- (void)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
               changeStateTo:(GKVideoHorizontalState)state;

/**
 *  回调当前 CurrentFrame 所在的 ChunkCell 的 index
 */
- (void)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
indexOfChunkCellAtCurrentFrame:(NSInteger)index;

/**
 *   回调拆分 ChunkCell 的 Index 和时间点
 */
- (void)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
            didDivideAtIndex:(NSInteger)index
                      atTime:(NSTimeInterval)time;

/**
 *  回调编辑过的 ChunkCell 的 index，开始时间和结束时间
 */
- (void)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
     chunkCellDidEditAtIndex:(NSInteger)index
                   beginTime:(NSTimeInterval)beginTime
                     endTime:(NSTimeInterval)endTime;

@end

@interface GKVideoHorizontalScrollView : GKHorizontalScrollView

@property (nonatomic, weak) IBOutlet id <GKVideoHorizontalScrollDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id <GKVideoHorizontalScrollViewLayout> layout;
@property (nonatomic, weak) IBOutlet id <GKVideoHorizontalScrollViewDelegate> delegate;

/**
 *  滚动到timeInterval所对应的位置
 */
- (void)scrollToTimeInterval:(NSTimeInterval)timeInterval animated:(BOOL)animated;

/**
 *  获取当前 的 ChunkCell 的 index
 */
- (NSInteger)indexOfChunkCell:(GKVideoChunkCell *)cell;

/**
 *  在CurrentFrame 位置分割 Cell
 */
- (void)attemptToDivideCellAtCurrentFrame;

/**
 *  添加一个 model
 */
- (void)appendCellModel:(id)cellModel;

/**
 *  当前所有片段的全部时长
 */
- (NSTimeInterval)totalTimeDuration;

@end
