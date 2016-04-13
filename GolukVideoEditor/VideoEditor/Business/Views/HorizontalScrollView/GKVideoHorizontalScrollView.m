//
//  GKVideoEditScrollView.m
//  GolukVideoEditor
//
//  Created by apple on 16/4/11.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKVideoHorizontalScrollView.h"
#import "GKVideoChunkCell.h"
#import "GKVideoFenceCell.h"
#import "GKVideoTailerCell.h"

@interface GKVideoHorizontalScrollView ()

@property (nonatomic, strong) UIImageView      * frameMarker;

@end

@implementation GKVideoHorizontalScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _frameMarker = [[UIImageView alloc] init];
        _frameMarker.backgroundColor = [UIColor redColor];
        [self addSubview:_frameMarker];
    }
    return self;
}

- (void)reloadData
{
    [super reloadData];
    CGFloat offsetOfFrameMarker = 0.0f;
    if ([self.layout respondsToSelector:@selector(defaultOffsetOfFrameMarkerOfHorizontalScrollView:)]) {
        offsetOfFrameMarker = [self.layout defaultOffsetOfFrameMarkerOfHorizontalScrollView:self];
    }
    self.frameMarker.frame = CGRectMake(offsetOfFrameMarker, 0, 1, CGRectGetHeight(self.frame));
}

- (CGFloat)offsetOfCurrentFrame
{
    return CGRectGetMidX(self.frameMarker.frame);
}

- (void)removeCell:(GKVideoChunkCell *)cell
{
    static BOOL IN_MOVING_ANIMATION = NO;
    if (IN_MOVING_ANIMATION == NO) {
        IN_MOVING_ANIMATION = YES;
        [UIView animateWithDuration:0.3f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             // 将要删除的 cell 的右边部分的 cell，向左移动
                             GKHorizontalCell * curCell = cell.rightFenceCell;
                             CGFloat xOffset = cell.frame.origin.x;
                             while (curCell) {
                                 GKHorizontalCell * rightCell = curCell.rightCell;
                                 
                                 UIEdgeInsets cellEdge = UIEdgeInsetsZero;
                                 // Cell Left Edge Insets
                                 if ([self.layout respondsToSelector:@selector(horizontalScrollView:insetForItemAtIndexPath:)]) {
                                     cellEdge = [self.layout horizontalScrollView:self
                                                          insetForItemAtIndexPath:nil];
                                 }
                                 xOffset += cellEdge.left;
                                 
                                 rightCell.frame = CGRectMake(xOffset,
                                                              0,
                                                              rightCell.frame.size.width,
                                                              rightCell.frame.size.height);
                                 
                                 xOffset += rightCell.frame.size.width;
                                 xOffset += cellEdge.right;
                                 
                                 // Next
                                 curCell = curCell.rightCell;
                             }
                         } completion:^(BOOL finished) {
                             IN_MOVING_ANIMATION = NO;
                             // 改变关系
                             GKHorizontalCell * leftFenceCell = cell.leftFenceCell;
                             GKHorizontalCell * rightChunkCell = cell.rightFenceCell.rightChunkCell;
                             leftFenceCell.rightCell = rightChunkCell;
                             rightChunkCell.leftCell = leftFenceCell;
                             
                             // 移除 cells
                             [cell.rightFenceCell removeFromSuperview];
                             [cell removeFromSuperview];
                         }];
    }
}

- (void)attemptToDivideCellAtCurrentFrame
{
    [self attemptToDivideCellWithOffset:[self offsetOfCurrentFrame]];
}

- (void)attemptToDivideCellWithOffset:(CGFloat)offset
{
    GKHorizontalCell * cell = [self seekCellForOffset:offset];
    
    // 如果不是GKVideoChunkCell
    if (![cell isKindOfClass:[GKVideoChunkCell class]]) {
        return;
    }
    
    // 计算offset 在 cell 中的比率
    CGFloat leftWidth = ([self offsetOfCurrentFrame] + self.contentOffsetOfScrollView - CGRectGetMinX(cell.frame));
    CGFloat rate = leftWidth / CGRectGetWidth(cell.frame);
    
    // 只允许某个区间的进行裁剪
    if (rate <= 0.1f || rate >= 0.9f) {
        return;
    }
    // 获取分割后的 cellModels
    GKVideoChunkCell * videoChunkCell = (GKVideoChunkCell *)cell;
    NSArray * subCellModels = [videoChunkCell divideAtRate:rate];
    
    // 获取新的 CellModels
    NSArray * newCellModels = [self.delegate horizontalScrollView:self
                             cellModelAfterInterceptDividedModels:subCellModels];
    
    NSAssert(newCellModels.count > 0, nil);

    GKHorizontalCell * theFirstNewCell = nil;
    GKHorizontalCell * theSecondNewCell = nil;
    GKHorizontalCell * theThirdNewCell = nil;
    
    // 根据 cellModels，得到新的 cell, 并且建立关系
    GKHorizontalCell * prevCell = cell.leftCell;
    for (id cellModel in newCellModels) {
        GKHorizontalCell * newCell = [self.dataSource horizontalScrollView:self
                                                          cellForItemModel:cellModel];
        CGSize size = [self.layout horizontalScrollView:self
                                       sizeForItemModel:cellModel];
        newCell.frame = CGRectMake(0, 0, size.width, size.height);
        [self addCell:newCell];
        
        // 建立关系
        prevCell.rightCell = newCell;
        newCell.leftCell = prevCell;
        prevCell = newCell;
        
        if (theFirstNewCell == nil) {
            theFirstNewCell = newCell;
            continue;
        }
        if (theSecondNewCell == nil) {
            theSecondNewCell = newCell;
            continue;
        }
        if (theThirdNewCell == nil) {
            theThirdNewCell = newCell;
            continue;
        }
    }
    
    // 查看 firstCell 是不是当前 divide 的, If YES, 则重置
    if (self.firstCell == cell) {
        self.firstCell = theFirstNewCell;
    }
    
    theFirstNewCell.frame = CGRectMake(CGRectGetMinX(cell.frame),
                                       0,
                                       CGRectGetWidth(theFirstNewCell.frame),
                                       CGRectGetHeight(theFirstNewCell.frame));
    theSecondNewCell.frame = CGRectMake(CGRectGetMaxX(theFirstNewCell.frame),
                                       0,
                                       CGRectGetWidth(theSecondNewCell.frame),
                                       CGRectGetHeight(theSecondNewCell.frame));
    theThirdNewCell.frame = CGRectMake(CGRectGetMaxX(theFirstNewCell.frame),
                                       0,
                                       CGRectGetWidth(theThirdNewCell.frame),
                                       CGRectGetHeight(theThirdNewCell.frame));
    
    cell.rightCell.leftCell = prevCell;
    prevCell.rightCell = cell.rightCell;
    
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGFloat xOffset = cell.frame.origin.x;
                         GKHorizontalCell * curCell = theFirstNewCell;
                         
                         while (curCell) {
                             UIEdgeInsets cellEdge = UIEdgeInsetsZero;
                             // Cell Left Edge Insets
                             if ([self.layout respondsToSelector:@selector(horizontalScrollView:insetForItemAtIndexPath:)]) {
                                 cellEdge = [self.layout horizontalScrollView:self
                                                      insetForItemAtIndexPath:nil];
                             }
                             if (curCell != theFirstNewCell) {
                                 xOffset += cellEdge.left;
                             }
                             
                             curCell.frame = CGRectMake(xOffset,
                                                        0,
                                                        curCell.frame.size.width,
                                                        curCell.frame.size.height);
                             
                             xOffset += curCell.frame.size.width;
                             xOffset += cellEdge.right;
                             
                             // Next
                             curCell = curCell.rightCell;
                         }
                     } completion:^(BOOL finished) {
                         [cell removeFromSuperview];
                     }];
}

- (void)scrollToTimeInterval:(NSTimeInterval)timeInterval animated:(BOOL)animated
{
    [self scrollToOffset:[self seekForTimeInterval:timeInterval] animated:animated];
}

- (CGFloat)seekForTimeInterval:(NSTimeInterval)timeInterval
{
    CGFloat xPosition = 0.0f;
    NSTimeInterval additionTimeInterval = 0.0f;
    GKVideoChunkCell * curCell = (GKVideoChunkCell *)self.firstCell;
    while (curCell) {
        CGFloat durationOfRate = curCell.cellModel.endPercent - curCell.cellModel.beginPercent;
        // 如果在这个 curCell 的duration中间
        if (additionTimeInterval <= timeInterval
            && timeInterval <= additionTimeInterval + curCell.cellModel.duration * durationOfRate) {
            break;
        }
        additionTimeInterval += curCell.cellModel.duration * durationOfRate;
        
        // 如果当前 cell 是最后一个 cell 了， 那么 break
        if (![curCell.rightFenceCell.rightChunkCell isKindOfClass:[GKVideoChunkCell class]]) {
            curCell = nil;
            break;
        }
        curCell = curCell.rightFenceCell.rightChunkCell;
    }
    // 如果不是GKVideoChunkCell， 那么返回0
    if (![curCell isKindOfClass:[GKVideoChunkCell class]]) {
        return 0.0f;
    }
    NSTimeInterval offsetOfTimeInterval = timeInterval - additionTimeInterval;

    xPosition = CGRectGetMinX(curCell.frame) - [self offsetOfCurrentFrame] + [GKVideoChunkCell widthOfOneSecond] * offsetOfTimeInterval;
    return xPosition;
}

#pragma mark - Override

- (void)attemptToUdpateFirstCellByMovingCell:(GKVideoChunkCell *)movingCell
                           withIntersectCell:(GKVideoChunkCell *)intersectCell
{
    // 如果firstCell是movingCell
    if (self.firstCell == movingCell) {
        self.firstCell = movingCell.rightFenceCell.rightChunkCell;
    }
    // 如果firstCell是intersectCell
    else if (self.firstCell == intersectCell) {
        self.firstCell = movingCell;
    }
}

- (void)doMovementFrom:(GKVideoChunkCell *)fromCell to:(GKVideoChunkCell *)toCell
{
    GKHorizontalDirection direction = [fromCell directionForCell:toCell];
    static BOOL IN_MOVING_ANIMATION = NO;
    if (IN_MOVING_ANIMATION == NO) {
        IN_MOVING_ANIMATION = YES;
        // 向右移动
        if (direction == GKHorizontalDirectionRight) {
            [UIView animateWithDuration:0.3f
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 GKVideoFenceCell * chunkFenceCell = fromCell.rightFenceCell;
                                 
                                 GKHorizontalCell * curCell = chunkFenceCell;
                                 // 起始的 x 值
                                 CGFloat xOffset = fromCell.originFrameInUpdating.origin.x;

                                 // Cell Left Edge Insets
                                 UIEdgeInsets cellEdge = UIEdgeInsetsZero;
                                 if ([self.layout respondsToSelector:@selector(horizontalScrollView:insetForItemAtIndexPath:)]) {
                                     cellEdge = [self.layout horizontalScrollView:self
                                                          insetForItemAtIndexPath:nil];
                                 }
                                 
                                 while (curCell) {
                                     GKHorizontalCell * rightCell = curCell.rightCell;
                                     if (curCell != chunkFenceCell) {
                                         xOffset += cellEdge.left;
                                     }
                                     
                                     rightCell.frame = CGRectMake(xOffset,
                                                                  0,
                                                                  rightCell.frame.size.width,
                                                                  rightCell.frame.size.height);
                                     
                                     xOffset += rightCell.frame.size.width;
                                     xOffset += cellEdge.right;
                                     
                                     // Next
                                     curCell = curCell.rightCell;
                                     if (curCell == toCell) {
                                         break;
                                     }
                                 }
                                 /************以下处理chunkFenceCell************/
                                 xOffset += cellEdge.left;
                                 chunkFenceCell.frame = CGRectMake(xOffset,
                                                                   0,
                                                                   chunkFenceCell.frame.size.width,
                                                                   chunkFenceCell.frame.size.height);
                                 xOffset += chunkFenceCell.frame.size.width;
                                 xOffset += cellEdge.right;
                             } completion:^(BOOL finished) {
                                 IN_MOVING_ANIMATION = NO;
                             }];
        } else if (direction == GKHorizontalDirectionLeft) {
            [UIView animateWithDuration:0.3f
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 GKVideoFenceCell * chunkFenceCell = fromCell.leftFenceCell;
                                 
                                 GKHorizontalCell * curCell = chunkFenceCell;
                                 // 起始的 x 值
                                 CGFloat xOffset = CGRectGetMaxX(fromCell.originFrameInUpdating);
                                 
                                 // Cell Left Edge Insets
                                 UIEdgeInsets cellEdge = UIEdgeInsetsZero;
                                 if ([self.layout respondsToSelector:@selector(horizontalScrollView:insetForItemAtIndexPath:)]) {
                                     cellEdge = [self.layout horizontalScrollView:self
                                                          insetForItemAtIndexPath:nil];
                                 }
                                 
                                 while (curCell) {
                                     GKHorizontalCell * leftCell = curCell.leftCell;
                                     if (curCell != chunkFenceCell) {
                                         xOffset -= cellEdge.right;
                                     }
                                     
                                     leftCell.frame = CGRectMake(xOffset - CGRectGetWidth(leftCell.frame),
                                                                 0,
                                                                 leftCell.frame.size.width,
                                                                 leftCell.frame.size.height);
                                     
                                     xOffset -= leftCell.frame.size.width;
                                     xOffset -= cellEdge.left;
                                     
                                     // Next
                                     curCell = curCell.leftCell;
                                     if (curCell == toCell) {
                                         break;
                                     }
                                 }
                                 /************以下处理chunkFenceCell************/
                                 xOffset -= cellEdge.right;
                                 chunkFenceCell.frame = CGRectMake(xOffset - CGRectGetWidth(chunkFenceCell.frame),
                                                                   0,
                                                                   chunkFenceCell.frame.size.width,
                                                                   chunkFenceCell.frame.size.height);
                                 xOffset -= chunkFenceCell.frame.size.width;
                                 xOffset -= cellEdge.left;
                             } completion:^(BOOL finished) {
                                 IN_MOVING_ANIMATION = NO;
                             }];
        }
    }
}

@end
