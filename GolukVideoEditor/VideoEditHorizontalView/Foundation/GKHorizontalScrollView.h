//
//  GKHorizontalScrollView.h
//  GolukVideoEditor
//
//  Created by apple on 16/4/10.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GKHorizontalCell;
@class GKHorizontalScrollView;

/*****************************
 * 数据源
 *****************************/
@protocol GKHorizontalScrollDataSource <NSObject>

@required

- (NSInteger)countOfHorizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView;

- (GKHorizontalCell *)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
                    cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

/*****************************
 * 布局
 *****************************/
@protocol GKHorizontalScrollViewLayout <NSObject>

@required

- (CGRect)rectOfScrollView:(GKHorizontalScrollView *)horizontalScrollView;

- (CGSize)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
        sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional

- (UIEdgeInsets)edgeInsetsOfHorizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView;

- (UIEdgeInsets)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
             insetForItemAtIndexPath:(NSIndexPath *)indexPath;

@end

/*****************************
 * 事件处理 Delegate
 *****************************/
@protocol GKHorizontalScrollViewDelegate <NSObject>

@optional

- (void)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
             offsetOfContent:(CGFloat)offset;
- (void)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
          cellDeletedAtIndex:(NSInteger)index;
- (void)didTouchDownBackground:(GKHorizontalScrollView *)horizontalScrollView;

@end

/*****************************
 * GKHorizontalScrollView
 *****************************/
@interface GKHorizontalScrollView : UIView

@property (nonatomic, weak) IBOutlet id <GKHorizontalScrollDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id <GKHorizontalScrollViewLayout> layout;
@property (nonatomic, weak) IBOutlet id <GKHorizontalScrollViewDelegate> delegate;

@property (nonatomic, weak) GKHorizontalCell * firstCell;

@property (nonatomic, strong, readonly) UIScrollView * scrollView;

- (void)reloadData;

- (void)scrollToOffset:(CGFloat)offset animated:(BOOL)animated;

/**
 * 查找当前 scrollView 的 contentOffset 的 cell
 * 这个 distance 是相对于 scrollView的左边距
 */
- (GKHorizontalCell *)seekCellWithLeftDistance:(CGFloat)distance;

/**
 * 获取 cell 的 index
 */
- (NSInteger)indexOfCell:(GKHorizontalCell *)cell;

/*****************************
 * Override
 *****************************/
- (void)refreshContentSize;

- (void)addCell:(GKHorizontalCell *)cell;

- (void)removeCell:(GKHorizontalCell *)cell;

/**
 * 如果 distance 是0， 那么删除的是当前 scrollView 的 contentOffset 的那一个 cell
 * 然后 distance 大于0，则是伤处的是当前 contentOffset + distance 的那一个 cell
 */
- (void)attemptToDivideCellWithLeftDistance:(CGFloat)distance;

- (void)attemptToUdpateFirstCellByMovingCell:(GKHorizontalCell *)moving
                           withIntersectCell:(GKHorizontalCell *)intersectCell;

- (void)horizontalScrollViewDidScroll:(UIScrollView *)scrollView;

- (void)didMoveCell:(GKHorizontalCell *)fromCell toCell:(GKHorizontalCell *)toCell;

- (void)didTouchDownBackground;

- (void)didLoadCell:(GKHorizontalCell *)cell;

@end
