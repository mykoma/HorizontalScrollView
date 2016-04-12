//
//  GKVideoEditScrollView.m
//  GolukVideoEditor
//
//  Created by apple on 16/4/11.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKVideoEditScrollView.h"
#import "GKVideoChunkCell.h"
#import "GKVideoChunkFenceCell.h"
#import "GKVideoChunkTailerCell.h"
#import "GKVideoAddChunkCell.h"
#import "GKVideoChunkTimeCell.h"

@interface GKVideoEditScrollView ()


@end

@implementation GKVideoEditScrollView

#pragma mark - ViewModel

- (void)setViewModel:(GKVideoEditScrollViewModel *)viewModel
{
    _viewModel = viewModel;
    [self buildInnerViewModels];
}

- (void)buildInnerViewModels
{
    [self.viewModel.innerCellModels removeAllObjects];
    
    for (GKVideoChunkCellModel * chunkCellModel in self.viewModel.chunkCellModels) {
        [self.viewModel.innerCellModels addObject:chunkCellModel];
        [self.viewModel.innerCellModels addObject:[GKVideoChunkFenceCellModel new]];
    }
    
    [self.viewModel.innerCellModels addObject:[GKVideoChunkTailerCellModel new]];
    [self.viewModel.innerCellModels addObject:[GKVideoAddChunkCellModel new]];
    [self.viewModel.innerCellModels addObject:[GKVideoChunkTimeCellModel new]];
}

#pragma mark - Override

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
                                 GKVideoChunkFenceCell * chunkFenceCell = fromCell.rightFenceCell;
                                 
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
                                 GKVideoChunkFenceCell * chunkFenceCell = fromCell.leftFenceCell;
                                 
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
