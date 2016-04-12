//
//  GKHorizontalScrollView.m
//  GolukVideoEditor
//
//  Created by apple on 16/4/10.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKHorizontalScrollView.h"
#import "GKHorizontalCell.h"

@interface GKHorizontalScrollView () <GKHorizontalCellDelegate>

@property (nonatomic, strong) NSMutableArray <GKHorizontalCell *> * cells;
@property (nonatomic, strong) UIScrollView * scrollView;
@property (nonatomic, assign) CGFloat xOffset;

@end

@implementation GKHorizontalScrollView

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
    self.cells = [NSMutableArray new];
    self.xOffset = 0.0f;
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.backgroundColor = [UIColor grayColor];
    self.scrollView.clipsToBounds = NO;
    [self addSubview:self.scrollView];
}

- (void)scrollToOffset:(CGFloat)offset
{
    self.scrollView.contentOffset = CGPointMake(offset, 0);
}

- (void)reloadData
{
    // Clear
    [self.cells removeAllObjects];
    
    // scrollView 布局
    CGRect scrollAreaFrame = [self.layout rectOfHorizontalScrollView:self];
    self.scrollView.frame = scrollAreaFrame;
    
    // 检查是否有 edge， 开始计算 xOffset
    UIEdgeInsets scrollViewEdge = UIEdgeInsetsZero;
    if ([self.layout respondsToSelector:@selector(edgeInsetsOfHorizontalScrollView:)]) {
        scrollViewEdge = [self.layout edgeInsetsOfHorizontalScrollView:self];
        self.xOffset += scrollViewEdge.left;
    }
    
    NSInteger rowCount = [self.dataSource countOfHorizontalScrollView:self];
    for (NSInteger index = 0; index < rowCount; index++) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        GKHorizontalCell * cell = [self.dataSource horizontalScrollView:self
                                                 cellForRowAtIndexPath:indexPath];
        [self.cells addObject:cell];
        cell.delegate = self;
        NSAssert(cell != nil, nil);
        if (cell != nil) {
            UIEdgeInsets cellEdge = UIEdgeInsetsZero;
            // Cell Left Edge Insets
            if ([self.layout respondsToSelector:@selector(horizontalScrollView:insetForItemAtIndexPath:)]) {
                cellEdge = [self.layout horizontalScrollView:self
                                     insetForItemAtIndexPath:indexPath];
            }
            self.xOffset += cellEdge.left;
            
            CGSize cellSize = [self.layout horizontalScrollView:self
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
    [self buildCellsRelation];
}

- (void)buildCellsRelation
{
    for (NSInteger index = 0; index < self.cells.count; index ++) {
        GKHorizontalCell * currentCell = self.cells[index];
        GKHorizontalCell * leftCell = nil;
        GKHorizontalCell * rightCell = nil;
        
        if (index > 0) {
            leftCell = self.cells[index - 1];
        }
        if (index < self.cells.count - 1) {
            rightCell = self.cells[index + 1];
        }
        if (leftCell) {
            leftCell.rightCell = currentCell;
            currentCell.leftCell = leftCell;
        }
        
        if (rightCell) {
            rightCell.leftCell = currentCell;
            currentCell.rightCell = rightCell;
        }
    }
}

#pragma mark - GKHorizontalCellDelegate

- (void)horizontalCell:(GKHorizontalCell *)horizontalCell
     moveBeganAtPoint:(CGPoint)point
{
    for (GKHorizontalCell * subview in self.scrollView.subviews) {
        if (![subview isKindOfClass:[GKHorizontalCell class]]) {
            continue;
        }
        [subview beginUpdating];
    }
}

- (void)horizontalCell:(GKHorizontalCell *)horizontalCell
         movingAtPoint:(CGPoint)point
{
    GKHorizontalCell * intersectCell = [self getIntersectCellByCell:horizontalCell withPoint:point];
    
    if ([intersectCell canExchange]) {
        [self doMovementFrom:horizontalCell to:intersectCell];
    } else {
        [self recoveryCellsFrameExceptCell:horizontalCell];
    }
}

- (void)horizontalCell:(GKHorizontalCell *)horizontalCell
       moveEndAtPoint:(CGPoint)point
{
    GKHorizontalCell * intersectCell = [self getIntersectCellByCell:horizontalCell withPoint:point];
    if ([intersectCell canExchange]) {
        if ([horizontalCell directionForCell:intersectCell] == GKHorizontalDirectionRight) {
            [UIView animateWithDuration:0.3f
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 horizontalCell.frame = CGRectMake(CGRectGetMaxX(intersectCell.originFrameInUpdating) - horizontalCell.originFrameInUpdating.size.width,
                                                                  horizontalCell.originFrameInUpdating.origin.y,
                                                                  horizontalCell.originFrameInUpdating.size.width,
                                                                  horizontalCell.originFrameInUpdating.size.height);
                             }
                             completion:^(BOOL finished) {
                                 [horizontalCell changeRelationWithCell:intersectCell];
                             }];
        } else if ([horizontalCell directionForCell:intersectCell] == GKHorizontalDirectionLeft) {
            [UIView animateWithDuration:0.3f
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 horizontalCell.frame = CGRectMake(intersectCell.originFrameInUpdating.origin.x,
                                                                  horizontalCell.originFrameInUpdating.origin.y,
                                                                  horizontalCell.originFrameInUpdating.size.width,
                                                                  horizontalCell.originFrameInUpdating.size.height);
                             }
                             completion:^(BOOL finished) {
                                 [horizontalCell changeRelationWithCell:intersectCell];
                             }];
        }
    } else {
        [self recoveryCellsFrameExceptCell:nil];
    }
    
    for (GKHorizontalCell * subview in self.scrollView.subviews) {
        if (![subview isKindOfClass:[GKHorizontalCell class]]) {
            continue;
        }
        [subview endUpdating];
    }
}

- (void)horizontalCell:(GKHorizontalCell *)horizontalCell
  moveCanceledAtPoint:(CGPoint)point
{
    
}

- (void)recoveryCellsFrameExceptCell:(GKHorizontalCell *)horizontalCell
{
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         for (GKHorizontalCell * subview in self.scrollView.subviews) {
                             if (![subview isKindOfClass:[GKHorizontalCell class]]) {
                                 continue;
                             }
                             if (subview == horizontalCell) {
                                 continue;
                             }
                             subview.frame = subview.originFrameInUpdating;
                         }
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void)doMovementFrom:(GKHorizontalCell *)fromCell to:(GKHorizontalCell *)toCell
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
                                 GKHorizontalCell * curCell = fromCell;
                                 CGFloat xOffset = fromCell.originFrameInUpdating.origin.x;
                                 while (curCell) {
                                     GKHorizontalCell * rightCell = curCell.rightCell;
                                     
                                     UIEdgeInsets cellEdge = UIEdgeInsetsZero;
                                     // Cell Left Edge Insets
                                     if ([self.layout respondsToSelector:@selector(horizontalScrollView:insetForItemAtIndexPath:)]) {
                                         cellEdge = [self.layout horizontalScrollView:self
                                                              insetForItemAtIndexPath:nil];
                                     }
                                     if (curCell != fromCell) {
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
                             } completion:^(BOOL finished) {
                                 IN_MOVING_ANIMATION = NO;
                             }];
        }
        // 向左移动
        else if (direction == GKHorizontalDirectionLeft) {
            [UIView animateWithDuration:0.3f
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 GKHorizontalCell * curCell = fromCell;
                                 CGFloat xOffset = CGRectGetMaxX(fromCell.originFrameInUpdating);
                                 while (curCell) {
                                     GKHorizontalCell * leftCell = curCell.leftCell;
                                     
                                     UIEdgeInsets cellEdge = UIEdgeInsetsZero;
                                     // Cell Left Edge Insets
                                     if ([self.layout respondsToSelector:@selector(horizontalScrollView:insetForItemAtIndexPath:)]) {
                                         cellEdge = [self.layout horizontalScrollView:self
                                                              insetForItemAtIndexPath:nil];
                                     }
                                     if (curCell != fromCell) {
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
                             } completion:^(BOOL finished) {
                                 IN_MOVING_ANIMATION = NO;
                             }];
        }
    }
}

#pragma mark - Get Intersect Cell

- (GKHorizontalCell *)getIntersectCellByCell:(GKHorizontalCell *)horizontalCell withPoint:(CGPoint)point
{
    GKHorizontalCell * intersectCell = nil;
    for (GKHorizontalCell * subview in self.scrollView.subviews) {
        if (![subview isKindOfClass:[GKHorizontalCell class]]) {
            continue;
        }
        if (subview == horizontalCell) {
            continue;
        }
        if (CGRectContainsPoint(subview.originFrameInUpdating, point)) {
            intersectCell = subview;
            break;
        }
    }
    return intersectCell;
}

@end
