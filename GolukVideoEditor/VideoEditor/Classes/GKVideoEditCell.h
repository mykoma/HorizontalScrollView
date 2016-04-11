//
//  GKVideoEditCell.h
//  GolukVideoEditor
//
//  Created by apple on 16/4/10.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, GKVideoEditDirection)
{
    GKVideoEditDirectionNone,
    GKVideoEditDirectionLeft,
    GKVideoEditDirectionRight,
};

@class GKVideoEditCell;

@protocol GKVideoEditCellDelegate <NSObject>

- (void)videoEditCell:(GKVideoEditCell *)videoEditCell
     moveBeganAtPoint:(CGPoint)point;

- (void)videoEditCell:(GKVideoEditCell *)videoEditCell
        movingAtPoint:(CGPoint)point;

- (void)videoEditCell:(GKVideoEditCell *)videoEditCell
       moveEndAtPoint:(CGPoint)point;

- (void)videoEditCell:(GKVideoEditCell *)videoEditCell
  moveCanceledAtPoint:(CGPoint)point;

@end

@interface GKVideoEditCell : UIView

@property (nonatomic, weak) IBOutlet id <GKVideoEditCellDelegate> delegate;
@property (nonatomic, assign, readonly) CGRect originFrameInUpdating;

@property (nonatomic, weak) GKVideoEditCell * leftCell;
@property (nonatomic, weak) GKVideoEditCell * rightCell;

- (void)setup;
/**
 * 获取 cell 在 self 的位置
 * eg. self ---- cell， 返回 GKVideoEditDirectionRight
 *     cell ---- self， 返回 GKVideoEditDirectionLeft
 */
- (GKVideoEditDirection)directionForCell:(GKVideoEditCell *)cell;

- (void)changeRelationWithCell:(GKVideoEditCell *)cell;

/**************** 开始更新 ***************/
- (void)beginUpdating;
- (void)endUpdating;

/**************** 子类重写 ***************/

/**
 * 能否长按移动，默认 NO
 */
- (BOOL)canMove;

/**
 * 能否能够和正在移动的 cell 移动位置，默认 NO
 */
- (BOOL)canExchange;

@end
