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

@property (nonatomic, strong) UIImageView * frameMarker;

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
    CGFloat x = 0.0f;
    if ([self.layout respondsToSelector:@selector(edgeInsetsOfHorizontalScrollView:)]) {
        x = [self.layout edgeInsetsOfHorizontalScrollView:self].left;
    }
    self.frameMarker.frame = CGRectMake(x, 0, 1, CGRectGetHeight(self.frame));
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
    CGFloat leftEdge = 0.0f;
    if ([self.layout respondsToSelector:@selector(edgeInsetsOfHorizontalScrollView:)]) {
        leftEdge = [self.layout edgeInsetsOfHorizontalScrollView:self].left;
    }
    
    xPosition = CGRectGetMinX(curCell.frame) - leftEdge + [GKVideoChunkCell widthOfOneSecond] * offsetOfTimeInterval;
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