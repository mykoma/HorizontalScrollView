//
//  GKHorizontalCell.h
//  GolukVideoEditor
//
//  Created by apple on 16/4/10.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, GKHorizontalDirection)
{
    GKHorizontalDirectionNone,
    GKHorizontalDirectionLeft,
    GKHorizontalDirectionRight,
};

@class GKHorizontalCell;

@protocol GKHorizontalCellDelegate <NSObject>

/**
 *  cell开始移动， 并且移动到 point
 */
- (void)horizontalCell:(GKHorizontalCell *)horizontalCell
      moveBeganAtPoint:(CGPoint)point;

/**
 *  cell移动到 point
 */
- (void)horizontalCell:(GKHorizontalCell *)horizontalCell
         movingAtPoint:(CGPoint)point;

/**
 *  cell移动结束，并且移动到 point
 */
- (void)horizontalCell:(GKHorizontalCell *)horizontalCell
       moveEndAtPoint:(CGPoint)point;

/**
 *  cell移动取消，并且移动到 point
 */
- (void)horizontalCell:(GKHorizontalCell *)horizontalCell
  moveCanceledAtPoint:(CGPoint)point;

@end

@interface GKHorizontalCell : UIView

@property (nonatomic, weak) IBOutlet id <GKHorizontalCellDelegate> delegate;
@property (nonatomic, assign, readonly) CGRect originFrameInUpdating;

@property (nonatomic, assign) BOOL enableMove;

/**
 *  当前 cell 左边的 cell
 */
@property (nonatomic, weak) GKHorizontalCell * leftCell;

/**
 *  当前 cell 右边的 cell
 */
@property (nonatomic, weak) GKHorizontalCell * rightCell;

/**
 *  Setup
 */
- (void)setup;
/**
 * 获取 cell 在 self 的位置
 * eg. self ---- cell， 返回 GKHorizontalDirectionRight
 *     cell ---- self， 返回 GKHorizontalDirectionLeft
 */
- (GKHorizontalDirection)directionForCell:(GKHorizontalCell *)cell;

/**
 *  改变 self 和 cell 的关系，以及 他们 leftCell, rightCell 的关系
 */
- (void)changeRelationWithCell:(GKHorizontalCell *)cell;

/**************** 开始更新 ***************/
- (void)beginUpdating;
- (void)endUpdating;

/**
 * 在指定比率的位置，分割 cell, 返回一个NSArray对象
 */
- (NSArray *)divideAtRate:(CGFloat)rate;

/**
 * 能否长按移动，默认 NO
 */
- (BOOL)canMove;

/**
 * 能否能够和正在移动的 cell 移动位置，默认 NO
 */
- (BOOL)canExchange;

@end
