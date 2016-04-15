//
//  GKHorizontalScrollView.m
//  GolukVideoEditor
//
//  Created by apple on 16/4/10.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKHorizontalScrollView.h"
#import "GKHorizontalCell.h"

@interface GKHorizontalScrollView ()
<
GKHorizontalCellDelegate,
UIScrollViewDelegate
>

@property (nonatomic, strong) NSMutableArray <GKHorizontalCell *> * cells;
@property (nonatomic, assign) CGFloat xOffset;
@property (nonatomic, weak  ) UIButton * backgroundBtn;
@property (nonatomic, strong, readwrite) UIScrollView * scrollView;

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
    
    UIButton * backgroundBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backgroundBtn addTarget:self
                      action:@selector(touchDownBackgroundBtn:)
            forControlEvents:UIControlEventTouchDown];
    [self addSubview:backgroundBtn];
    self.backgroundBtn = backgroundBtn;
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.clipsToBounds = NO;
    [self addSubview:self.scrollView];
}

- (void)layoutSubviews
{
    self.backgroundBtn.frame = self.bounds;
}

- (void)scrollToOffset:(CGFloat)offset animated:(BOOL)animated
{
    [self.scrollView setContentOffset:CGPointMake(offset, 0) animated:animated];
}

- (CGFloat)contentOffsetOfScrollView
{
    return self.scrollView.contentOffset.x;
}

- (void)addCell:(GKHorizontalCell *)cell
{
    cell.delegate = self;
    [self.scrollView addSubview:cell];
}

- (void)removeCell:(GKHorizontalCell *)cell
{
    static BOOL IN_MOVING_ANIMATION = NO;
    if (IN_MOVING_ANIMATION == NO) {
        IN_MOVING_ANIMATION = YES;
        [UIView animateWithDuration:0.3f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             GKHorizontalCell * curCell = cell;
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
                             GKHorizontalCell * leftCell = cell.leftCell;
                             GKHorizontalCell * rightCell = cell.rightCell;
                             leftCell.rightCell = rightCell;
                             rightCell.leftCell = leftCell;
                             [cell removeFromSuperview];
                         }];
    }
}

- (GKHorizontalCell *)seekCellWithLeftDistance:(CGFloat)distance
{
    CGFloat seekedOffset = distance + self.scrollView.contentOffset.x;
    GKHorizontalCell * seekedCell= nil;
    GKHorizontalCell * curCell = self.firstCell;
    
    while (curCell) {
        if (CGRectGetMinX(curCell.frame) <= seekedOffset
            && seekedOffset <= CGRectGetMaxX(curCell.frame)) {
            seekedCell = curCell;
            break;
        }
        curCell = curCell.rightCell;
    }
    return seekedCell;
}

- (NSInteger)indexOfCell:(GKHorizontalCell *)cell
{
    NSInteger index = 0;
    GKHorizontalCell * curCell = self.firstCell;
    while (curCell) {
        if (curCell == cell) {
            break;
        }
        curCell = curCell.rightCell;
        index ++;
    }
    return index;
}

- (void)attemptToDivideCellWithLeftDistance:(CGFloat)offset
{
    // TODO
}

- (void)reloadData
{
    // Clear
    [self.cells removeAllObjects];
    
    // scrollView 布局
    CGRect scrollAreaFrame = [self.layout rectOfScrollView:self];
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
        NSAssert(cell != nil, nil);
        
        cell.delegate = self;
        [self.cells addObject:cell];
        
        // 如果没有 firstCell， 则设置
        if (self.firstCell == nil) {
            self.firstCell = cell;
        }
        
        // 给 cell 布局
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
    
    // 建立关系
    [self buildCellsRelation];

    // 设置 scrollview 的滚动区域
    [self refreshContentSize];
}

- (void)refreshContentSize
{
    GKHorizontalCell * curCell = self.firstCell;
    // seek the end cell
    while (curCell) {
        if (curCell.rightCell == nil) {
            break;
        }
        curCell = curCell.rightCell;
    }
    CGFloat rightEdge = 0.0f;
    if ([self.layout respondsToSelector:@selector(edgeInsetsOfHorizontalScrollView:)]) {
        rightEdge += [self.layout edgeInsetsOfHorizontalScrollView:self].right;
    }
    self.scrollView.contentSize = CGSizeMake(CGRectGetMaxX(curCell.frame) + rightEdge, 0);
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

- (void)didTouchDownBackground
{
    if ([self.delegate respondsToSelector:@selector(didTouchDownBackground:)]) {
        [self.delegate didTouchDownBackground:self];
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
                                 [self didMoveCell:horizontalCell toCell:intersectCell];
                                 [self attemptToUdpateFirstCellByMovingCell:horizontalCell
                                                          withIntersectCell:intersectCell];
                                 [horizontalCell changeRelationWithCell:intersectCell];
                             }];
        } else if ([horizontalCell directionForCell:intersectCell] == GKHorizontalDirectionLeft) {
            [UIView animateWithDuration:0.3f
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 [self didMoveCell:horizontalCell toCell:intersectCell];
                                 horizontalCell.frame = CGRectMake(intersectCell.originFrameInUpdating.origin.x,
                                                                  horizontalCell.originFrameInUpdating.origin.y,
                                                                  horizontalCell.originFrameInUpdating.size.width,
                                                                  horizontalCell.originFrameInUpdating.size.height);
                             }
                             completion:^(BOOL finished) {
                                 [self attemptToUdpateFirstCellByMovingCell:horizontalCell
                                                          withIntersectCell:intersectCell];
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

- (void)didMoveCell:(GKHorizontalCell *)fromCell toCell:(GKHorizontalCell *)toCell
{
    // Empty
}

- (void)horizontalCell:(GKHorizontalCell *)horizontalCell
  moveCanceledAtPoint:(CGPoint)point
{
    
}

- (void)attemptToUdpateFirstCellByMovingCell:(GKHorizontalCell *)movingCell
                           withIntersectCell:(GKHorizontalCell *)intersectCell
{
    // 如果firstCell是movingCell
    if (self.firstCell == movingCell) {
        self.firstCell = movingCell.rightCell;
    }
    // 如果firstCell是intersectCell
    else if (self.firstCell == intersectCell) {
        self.firstCell = movingCell;
    }
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

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self horizontalScrollViewDidScroll:scrollView];
}

- (void)horizontalScrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(horizontalScrollView:offsetOfContent:)]) {
        [self.delegate horizontalScrollView:self offsetOfContent:scrollView.contentOffset.x];
    }
}

#pragma mark - Action

- (void)touchDownBackgroundBtn:(id)sender
{
    [self didTouchDownBackground];
}

@end
