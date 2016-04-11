//
//  GKVideoEditScrollView.m
//  GolukVideoEditor
//
//  Created by apple on 16/4/10.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKVideoEditScrollView.h"
#import "GKVideoEditCell.h"

@interface GKVideoEditScrollView () <GKVideoEditCellDelegate>

@property (nonatomic, strong) UIScrollView * scrollView;
@property (nonatomic, assign) CGFloat xOffset;

@end

@implementation GKVideoEditScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.xOffset = 0.0f;
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.backgroundColor = [UIColor grayColor];
    self.scrollView.clipsToBounds = NO;
    [self addSubview:self.scrollView];
}

- (void)reloadData
{
    // scrollView 布局
    CGRect videoScrollAreaFrame = [self.layout rectOfVideoEditScrollView:self];
    self.scrollView.frame = videoScrollAreaFrame;
    
    // 检查是否有 edge， 开始计算 xOffset
    UIEdgeInsets scrollViewEdge = UIEdgeInsetsZero;
    if ([self.layout respondsToSelector:@selector(edgeInsetsOfVideoEditScrollView:)]) {
        scrollViewEdge = [self.layout edgeInsetsOfVideoEditScrollView:self];
        self.xOffset += scrollViewEdge.left;
    }
    
    NSInteger rowCount = [self.dataSource countOfVideoEditScrollView:self];
    for (NSInteger index = 0; index < rowCount; index++) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        GKVideoEditCell * cell = [self.dataSource videoEditScrollView:self
                                                cellForRowAtIndexPath:indexPath];
        cell.delegate = self;
        NSAssert(cell != nil, nil);
        if (cell != nil) {
            UIEdgeInsets cellEdge = UIEdgeInsetsZero;
            // Cell Left Edge Insets
            if ([self.layout respondsToSelector:@selector(videoEditScrollView:insetForItemAtIndexPath:)]) {
                cellEdge = [self.layout videoEditScrollView:self
                                insetForItemAtIndexPath:indexPath];
            }
            self.xOffset += cellEdge.left;
            
            CGSize cellSize = [self.layout videoEditScrollView:self
                                        sizeForItemAtIndexPath:indexPath];
            cell.frame = CGRectMake(self.xOffset, 0, cellSize.width, cellSize.height);
            [self.scrollView addSubview:cell];
            
            self.xOffset += cellSize.width;
            self.xOffset += cellEdge.right;
        }
    }
    self.xOffset += scrollViewEdge.right;
    // 设置 scrollview 的滚动区域
    self.scrollView.contentSize = CGSizeMake(self.xOffset, 0);
}

#pragma mark - GKVideoEditCellDelegate

- (void)videoEditCell:(GKVideoEditCell *)videoEditCell
     moveBeganAtPoint:(CGPoint)point
{
    for (GKVideoEditCell * subview in self.scrollView.subviews) {
        if (![subview isKindOfClass:[GKVideoEditCell class]]) {
            continue;
        }
        [subview beginUpdating];
    }
}

- (void)videoEditCell:(GKVideoEditCell *)videoEditCell
         changeCenter:(CGPoint)newCenter
{
    GKVideoEditCell * intersectCell = [self getIntersectCellByCell:videoEditCell];
    
    if (intersectCell) {
        static BOOL IN_MOVING_ANIMATION = NO;
        if (IN_MOVING_ANIMATION == NO) {
            IN_MOVING_ANIMATION = YES;
            [UIView animateWithDuration:0.3f
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 intersectCell.frame = CGRectOffset(intersectCell.originFrameInUpdating,
                                                              videoEditCell.originFrameInUpdating.origin.x - intersectCell.originFrameInUpdating.origin.x,
                                                              0);
                             }
                             completion:^(BOOL finished) {
                                 IN_MOVING_ANIMATION = NO;
                             }];
        }
    }
}

- (void)videoEditCell:(GKVideoEditCell *)videoEditCell
       moveEndAtPoint:(CGPoint)point
{
    GKVideoEditCell * intersectCell = [self getIntersectCellByCell:videoEditCell];
    if (intersectCell) {
        [UIView animateWithDuration:0.3f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             videoEditCell.frame = CGRectMake(CGRectGetMaxX(intersectCell.originFrameInUpdating) - videoEditCell.originFrameInUpdating.size.width,
                                                              videoEditCell.originFrameInUpdating.origin.y,
                                                              videoEditCell.originFrameInUpdating.size.width,
                                                              videoEditCell.originFrameInUpdating.size.height);
                         }
                         completion:^(BOOL finished) {
                         }];
    } else {
        [self revertVideoEditCells];
    }
    
    for (GKVideoEditCell * subview in self.scrollView.subviews) {
        if (![subview isKindOfClass:[GKVideoEditCell class]]) {
            continue;
        }
        [subview endUpdating];
    }
}

- (void)videoEditCell:(GKVideoEditCell *)videoEditCell
  moveCanceledAtPoint:(CGPoint)point
{
    
}

- (void)revertVideoEditCells
{
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         for (GKVideoEditCell * subview in self.scrollView.subviews) {
                             if (![subview isKindOfClass:[GKVideoEditCell class]]) {
                                 continue;
                             }
                             subview.frame = subview.originFrameInUpdating;
                         }
                     } completion:^(BOOL finished) {
                         
                     }];
}

#pragma mark - Get Intersect Cell

- (GKVideoEditCell *)getIntersectCellByCell:(GKVideoEditCell *)videoEditCell
{
    GKVideoEditCell * intersectCell = nil;
    for (GKVideoEditCell * subview in self.scrollView.subviews) {
        if (![subview isKindOfClass:[GKVideoEditCell class]]) {
            continue;
        }
        if (subview == videoEditCell) {
            continue;
        }
        if (CGRectIntersectsRect(videoEditCell.frame, subview.originFrameInUpdating)) {
            intersectCell = subview;
            break;
        }
    }
    return intersectCell;
}

@end
