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
#import "GKVideoCurrentFrameView.h"

@interface GKVideoHorizontalScrollView () <GKVideoChunkCellDelegate>

@property (nonatomic, strong           ) GKVideoCurrentFrameView * frameMarker;
@property (nonatomic, weak             ) GKVideoChunkCell        * chunkCellAtCurrentFrame;
@property (nonatomic, assign           ) BOOL                    couldSplitAtCurrentFrame;
@property (nonatomic, assign, readwrite) GKVideoHorizontalState  state;

@end

@implementation GKVideoHorizontalScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _frameMarker = [[GKVideoCurrentFrameView alloc] init];
        _state = GKVideoHorizontalStateNormal;
        _couldSplitAtCurrentFrame = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(chunkCellBecomeEdit:)
                                                     name:GK_VIDEO_CHUNK_CELL_NOTIFICATION_BECOME_EDIT
                                                   object:nil];
        
        [self addSubview:_frameMarker];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadData
{
    [super reloadData];
    [self setFrameMarkerToDefaultPostion];
    [self refreshContentSize];
}

- (void)setFrameMarkerToDefaultPostion
{
    CGFloat offsetOfFrameMarker = 0.0f;
    if ([self.layout respondsToSelector:@selector(defaultOffsetOfCurrentFrameOfHorizontalScrollView:)]) {
        offsetOfFrameMarker = [self.layout defaultOffsetOfCurrentFrameOfHorizontalScrollView:self];
    }
    self.frameMarker.frame = CGRectMake(offsetOfFrameMarker, 0, 0.5, CGRectGetHeight(self.frame));
}

- (NSInteger)indexOfChunkCell:(GKVideoChunkCell *)cell
{
    NSAssert([cell isKindOfClass:[GKVideoChunkCell class]], nil);
    
    NSInteger index = 0;
    GKVideoChunkCell * curCell = (GKVideoChunkCell *)self.firstCell;
    while ([curCell isKindOfClass:[GKVideoChunkCell class]]) {
        if (curCell == cell) {
            break;
        }
        if (![curCell.rightCell.rightCell isKindOfClass:[GKVideoChunkCell class]]) {
            NSAssert(NO, @"没有找到 cell 的 index");
            break;
        }
        curCell = curCell.rightFenceCell.rightChunkCell;
        index ++;
    }
    return index;
}

- (CGFloat)offsetOfCurrentFrame
{
    return CGRectGetMidX(self.frameMarker.frame);
}

- (CGFloat)offsetOfCurrentFrameInScrollView
{
    return [self offsetOfCurrentFrame] + self.scrollView.contentOffset.x;
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
                             UIEdgeInsets cellEdge = self.cellEdge;
                             while (curCell) {
                                 GKHorizontalCell * rightCell = curCell.rightCell;
                                 
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
                             NSInteger indexOfChunkCell = [self indexOfChunkCell:cell];
                             
                             // 改变关系
                             GKHorizontalCell * leftFenceCell = cell.leftFenceCell;
                             GKHorizontalCell * rightChunkCell = cell.rightFenceCell.rightChunkCell;
                             leftFenceCell.rightCell = rightChunkCell;
                             rightChunkCell.leftCell = leftFenceCell;
                             
                             if (cell == self.firstCell) {
                                 self.firstCell = cell.rightFenceCell.rightCell;
                             }
                             
                             // 移除 cells
                             [cell.rightFenceCell removeFromSuperview];
                             [cell removeFromSuperview];
                             
                             self.state = GKVideoHorizontalStateNormal;
                             if ([self.delegate respondsToSelector:@selector(horizontalScrollView:chunkCellDidDeleteAtIndex:)]) {
                                 [self.delegate horizontalScrollView:self
                                           chunkCellDidDeleteAtIndex:indexOfChunkCell];
                             }
                             
                             [self adjustContentSizeAndOffset];
                         }];
    }
}

- (void)attemptToSplitCellAtCurrentFrame
{
    [self attemptToSplitCellWithLeftDistance:[self offsetOfCurrentFrame]];
}

- (void)appendCellModel:(id)cellModel
{
    // 获取新的 CellModels
    NSArray * newCellModels = [self.delegate horizontalScrollView:self
                              cellModelAfterInterceptAppendModels:@[cellModel]];
    NSAssert(newCellModels.count > 0, nil);
    
    GKHorizontalCell * theFirstNewCell = nil;
    GKHorizontalCell * theSecondNewCell = nil;
    
    GKVideoChunkCell * lastChunkCell = [self lastChunkCell];
    
    GKHorizontalCell * theOldRightCell = (lastChunkCell == nil) ? self.firstCell : lastChunkCell.rightFenceCell.rightCell;
    // 根据 cellModels，得到新的 cell, 并且建立关系
    GKHorizontalCell * prevCell = lastChunkCell.rightFenceCell;
    for (id cellModel in newCellModels) {
        GKHorizontalCell * newCell = [self.dataSource horizontalScrollView:self
                                                          cellForItemModel:cellModel];
        [self didLoadCell:newCell];
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
    }
    theOldRightCell.leftCell = prevCell;
    prevCell.rightCell = theOldRightCell;
    
    if (lastChunkCell == nil) {
        self.firstCell = theFirstNewCell;
    }
    
    theFirstNewCell.frame = CGRectMake(CGRectGetMinX(theOldRightCell.frame),
                                       0,
                                       CGRectGetWidth(theFirstNewCell.frame),
                                       CGRectGetHeight(theFirstNewCell.frame));
    theSecondNewCell.frame = CGRectMake(CGRectGetMinX(theFirstNewCell.frame),
                                        0,
                                        CGRectGetWidth(theSecondNewCell.frame),
                                        CGRectGetHeight(theSecondNewCell.frame));
    
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGFloat xOffset = theOldRightCell.frame.origin.x;
                         GKHorizontalCell * curCell = theFirstNewCell;
                         UIEdgeInsets cellEdge = self.cellEdge;
                         while (curCell) {
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
                         self.state = GKVideoHorizontalStateNormal;
                         [self adjustContentSizeAndOffset];
                     }];
}

- (void)attemptToSplitCellWithLeftDistance:(CGFloat)distance
{
    if (!self.couldSplitAtCurrentFrame) {
        return;
    }

    GKHorizontalCell * cell = [self seekCellWithLeftDistance:distance];
    
    // 如果不是GKVideoChunkCell
    if (![cell isKindOfClass:[GKVideoChunkCell class]]) {
        return;
    }
    
    // 计算offset 在 cell 中的比率
    CGFloat leftWidth = (distance + self.scrollView.contentOffset.x - CGRectGetMinX(cell.frame));
    CGFloat rate = leftWidth / CGRectGetWidth(cell.frame);

    // 获取分割后的 cellModels
    GKVideoChunkCell * videoChunkCell = (GKVideoChunkCell *)cell;
    NSArray * subCellModels = [videoChunkCell splitAtRate:rate];
    
    // 获取新的 CellModels
    NSArray * newCellModels = [self.delegate horizontalScrollView:self
                             cellModelAfterInterceptSplitdModels:subCellModels];
    
    NSAssert(newCellModels.count > 0, nil);

    GKHorizontalCell * theFirstNewCell = nil;
    GKHorizontalCell * theSecondNewCell = nil;
    GKHorizontalCell * theThirdNewCell = nil;
    
    // 根据 cellModels，得到新的 cell, 并且建立关系
    GKHorizontalCell * prevCell = cell.leftCell;
    for (id cellModel in newCellModels) {
        GKHorizontalCell * newCell = [self.dataSource horizontalScrollView:self
                                                          cellForItemModel:cellModel];
        [self didLoadCell:newCell];
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
    cell.rightCell.leftCell = prevCell;
    prevCell.rightCell = cell.rightCell;
    
    // 查看 firstCell 是不是当前 split 的, If YES, 则重置
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
    
    __block CGFloat xOffset = cell.frame.origin.x;
    [cell removeFromSuperview];

    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         GKHorizontalCell * curCell = theFirstNewCell;
                         UIEdgeInsets cellEdge = self.cellEdge;
                         while (curCell) {
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
                         self.state = GKVideoHorizontalStateNormal;
                         [self adjustContentSizeAndOffset];
                     }];
}

- (void)adjustContentSizeAndOffset
{
    // Workaround.
    // Bug: refreshContentSize 更新 contentSize 会被改变，目前详细原因未知
    CGPoint recordOffset = self.scrollView.contentOffset;
    [self refreshContentSize];
    self.scrollView.contentOffset = recordOffset;
}

- (void)refreshContentSize
{
    [super refreshContentSize];
    CGFloat contentWidth = self.scrollView.contentSize.width + (CGRectGetWidth(self.frame) - [self offsetOfCurrentFrame]);
    self.scrollView.contentSize = CGSizeMake(contentWidth, 0);
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
        NSTimeInterval durationOfVisible = curCell.cellModel.endTime - curCell.cellModel.beginTime;
        // 如果在这个 curCell 的duration中间
        if (additionTimeInterval <= timeInterval
            && timeInterval <= additionTimeInterval + durationOfVisible) {
            break;
        }
        additionTimeInterval += durationOfVisible;
        
        // 如果当前 curCell 是最后一个 cell 了， 那么 break
        if (![curCell.rightCell.rightCell isKindOfClass:[GKVideoChunkCell class]]) {
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

- (NSTimeInterval)totalTimeDuration
{
    // totalDuration 不包含视频尾
    NSTimeInterval totalDuration = 0.0f;
    GKVideoChunkCell * curCell = (GKVideoChunkCell *)self.firstCell;
    while ([curCell isKindOfClass:[GKVideoChunkCell class]]) {
        totalDuration += curCell.cellModel.endTime - curCell.cellModel.beginTime;
        
        // 如果当前 curCell 是最后一个 cell 了， 那么 break
        if (![curCell.rightCell.rightCell isKindOfClass:[GKVideoChunkCell class]]) {
            break;
        }
        curCell = curCell.rightFenceCell.rightChunkCell;
    }
    return totalDuration;
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

- (void)didMoveCell:(GKHorizontalCell *)fromCell toCell:(GKHorizontalCell *)toCell
{
    NSAssert([fromCell isKindOfClass:[GKVideoChunkCell class]], nil);
    NSAssert([toCell isKindOfClass:[GKVideoChunkCell class]], nil);
    if ([self.delegate respondsToSelector:@selector(horizontalScrollView:chunkCellMoveFromIndex:toIndex:)]) {
        [self.delegate horizontalScrollView:self
                     chunkCellMoveFromIndex:[self indexOfChunkCell:(GKVideoChunkCell *)fromCell]
                                    toIndex:[self indexOfChunkCell:(GKVideoChunkCell *)toCell]];
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
                                 UIEdgeInsets cellEdge = self.cellEdge;
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
                                 UIEdgeInsets cellEdge = self.cellEdge;
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

- (void)horizontalScrollViewDidScroll:(UIScrollView *)scrollView
{
    [super horizontalScrollViewDidScroll:scrollView];
    GKHorizontalCell * cell = [self seekCellWithLeftDistance:[self offsetOfCurrentFrame]];
    
    if ([cell isKindOfClass:[GKVideoChunkCell class]] && self.chunkCellAtCurrentFrame != cell) {
        self.chunkCellAtCurrentFrame = (GKVideoChunkCell *)cell;
        // 如果当前是编辑状态并且当前是用户在滚动， 那么更新 cell 的状态
        if (self.state == GKVideoHorizontalStateEdit && self.isScrollingByManual) {
            [self.chunkCellAtCurrentFrame becomeToEditState];
        }
        if ([self.delegate respondsToSelector:@selector(horizontalScrollView:chunkCellOfCurrentFrameChangedAtIndex:)]) {
            [self.delegate horizontalScrollView:self
          chunkCellOfCurrentFrameChangedAtIndex:[self indexOfChunkCell:self.chunkCellAtCurrentFrame]];
        }
    }
    if ([self.delegate respondsToSelector:@selector(horizontalScrollView:timeIntervalOfScrollOffset:)])
    {
        NSTimeInterval timeInterval = [self timeIntervalOfHorizontalScrollOffset:scrollView.contentOffset.x];
        [self.delegate horizontalScrollView:self timeIntervalOfScrollOffset:timeInterval];
    }

    BOOL couldSplit = YES;
    // 如果不是GKVideoChunkCell
    if (![cell isKindOfClass:[GKVideoChunkCell class]]) {
        couldSplit = NO;
    } else {
        CGFloat leftWidth = ([self offsetOfCurrentFrame] + self.scrollView.contentOffset.x - CGRectGetMinX(cell.frame));
        CGFloat rightWidth = CGRectGetWidth(cell.frame) - leftWidth;
        CGFloat minimumWidthOfChunkCell = [GKVideoChunkCell minimumWidthOfChunkCell];
        couldSplit = leftWidth >= minimumWidthOfChunkCell && rightWidth >= minimumWidthOfChunkCell;
    }
    if (self.couldSplitAtCurrentFrame != couldSplit) {
        self.couldSplitAtCurrentFrame = couldSplit;
        if ([self.delegate respondsToSelector:@selector(horizontalScrollView:couldSplitAtCurrentFrame:)]) {
            [self.delegate horizontalScrollView:self couldSplitAtCurrentFrame:couldSplit];
        }
    }
}

- (void)horizontalScrollViewFinishScroll:(UIScrollView *)scrollView
{
    [super horizontalScrollViewFinishScroll:scrollView];
    GKHorizontalCell * cell = [self seekNearestCellWithLeftDistance:[self offsetOfCurrentFrame]];
    if (![cell isKindOfClass:[GKVideoChunkCell class]]) {
        // 查看左边的 cell
        GKHorizontalCell * leftCell = cell.leftCell;
        while (leftCell) {
            if ([leftCell isKindOfClass:[GKVideoChunkCell class]]) {
                break;
            }
            leftCell = leftCell.leftCell;
        }
        // 查看右边的 cell
        GKHorizontalCell * rightCell = cell.rightCell;
        while (rightCell) {
            if ([rightCell isKindOfClass:[GKVideoChunkCell class]]) {
                break;
            }
            rightCell = rightCell.rightCell;
        }
        
        if (leftCell == nil) {
            [self scrollToOffset:CGRectGetMinX(rightCell.frame) - [self offsetOfCurrentFrame]
                        animated:YES];
        } else if (rightCell == nil) {
            [self scrollToOffset:CGRectGetMaxX(leftCell.frame) - [self offsetOfCurrentFrame]
                        animated:YES];
        } else {
            CGFloat leftDistance = [self offsetOfCurrentFrameInScrollView] - CGRectGetMaxX(leftCell.frame);
            CGFloat rightDistance = CGRectGetMinX(rightCell.frame) - [self offsetOfCurrentFrameInScrollView];
            if (leftDistance <= rightDistance) {
                [self scrollToOffset:CGRectGetMaxX(leftCell.frame) - [self offsetOfCurrentFrame]
                            animated:YES];
            } else {
                [self scrollToOffset:CGRectGetMinX(rightCell.frame) - [self offsetOfCurrentFrame]
                            animated:YES];
            }
        }
    } else {
        if ([self offsetOfCurrentFrameInScrollView] < CGRectGetMinX(cell.frame)) {
            [self scrollToOffset:CGRectGetMinX(cell.frame) - [self offsetOfCurrentFrame]
                        animated:YES];
        } else if (CGRectGetMaxX(cell.frame) < [self offsetOfCurrentFrameInScrollView] ) {
            [self scrollToOffset:CGRectGetMaxX(cell.frame) - [self offsetOfCurrentFrame]
                        animated:YES];
        }
    }
}

- (void)didTouchDownBackground
{
    [super didTouchDownBackground];
    [self resetToNormalState];
}

- (void)resetToNormalState
{
    [GKVideoChunkCell resignEditState];
    if (self.state != GKVideoChunkCellStateNormal) {
        self.state = GKVideoHorizontalStateNormal;
    }
}

- (void)didLoadCell:(GKHorizontalCell *)cell
{
    if ([cell isKindOfClass:[GKVideoChunkCell class]]) {
        GKVideoChunkCell * chunkCell = (GKVideoChunkCell *)cell;
        chunkCell.chunkCellDelegate = self;
    }
}

- (void)setState:(GKVideoHorizontalState)state
{
    if (_state == state) {
        return;
    }
    _state = state;
    // 当前 view 的状态改变的时候， 那么则修改所有的 chunkCell， 改变他们的状态
    if (_state == GKVideoHorizontalStateNormal) {
        [GKVideoChunkCell resignEditState];
    }
    if ([self.delegate respondsToSelector:@selector(horizontalScrollView:changeStateTo:)]) {
        [self.delegate horizontalScrollView:self changeStateTo:self.state];
    }
}

#pragma mark - Private

- (GKVideoChunkCell *)lastChunkCell
{
    GKVideoChunkCell * curCell = (GKVideoChunkCell *)self.firstCell;
    while ([curCell isKindOfClass:[GKVideoChunkCell class]]) {
        if (![curCell.rightCell.rightCell isKindOfClass:[GKVideoChunkCell class]]) {
            break;
        }
        curCell = curCell.rightFenceCell.rightChunkCell;
    }
    return [curCell isKindOfClass:[GKVideoChunkCell class]] ? curCell : nil;
}

- (NSTimeInterval)timeIntervalOfHorizontalScrollOffset:(CGFloat)offset
{
    GKHorizontalCell * cell = [self seekNearestCellWithLeftDistance:[self offsetOfCurrentFrame]];
    NSTimeInterval timeInterval = 0.0f;
    GKHorizontalCell * curCell = cell.leftCell;
    while (curCell) {
        if ([curCell isKindOfClass:[GKVideoChunkCell class]]) {
            GKVideoChunkCell * chunkCell = (GKVideoChunkCell *)curCell;
            timeInterval += chunkCell.cellModel.endTime - chunkCell.cellModel.beginTime;
        }
        curCell = curCell.leftCell;
    }

    if ([cell isKindOfClass:[GKVideoChunkCell class]]) {
        timeInterval += [GKVideoChunkCell durationOfWidth:([self offsetOfCurrentFrame] + offset - CGRectGetMinX(cell.frame))];
    }

    return timeInterval;
}

- (void)chunkCellBecomeEdit:(NSNotification *)notification
{
    if (self.state != GKVideoHorizontalStateEdit) {
        self.state = GKVideoHorizontalStateEdit;
    }
}

#pragma mark - GKVideoChunkCellDelegate

- (void)chunkCell:(GKVideoChunkCell *)chunkCell frameBeganChangedOnLeftSide:(CGRect)changedFrame
{
    [self updateCellsFrameOnLeftSideFromCell:chunkCell.leftCell
                              toTailPosition:CGRectGetMinX(changedFrame) - self.cellEdge.left
                                   animation:NO
                                  completion:NULL];
    [UIView animateWithDuration:0.2f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect changedFrameInSelfView = [self convertRect:changedFrame fromView:self.scrollView];
                         self.frameMarker.frame = CGRectMake(CGRectGetMinX(changedFrameInSelfView),
                                                             0,
                                                             CGRectGetWidth(self.frameMarker.frame),
                                                             CGRectGetHeight(self.frameMarker.frame));
                     } completion:^(BOOL finished) {
                     }];
}

- (void)chunkCell:(GKVideoChunkCell *)chunkCell frameBeganChangedOnRightSide:(CGRect)changedFrame
{
    [self updateCellsFrameOnRightSideFromCell:chunkCell.rightCell
                               toLeadPosition:CGRectGetMaxX(changedFrame) + self.cellEdge.right
                                    animation:NO
                                   completion:NULL];
    [UIView animateWithDuration:0.2f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect changedFrameInSelfView = [self convertRect:changedFrame fromView:self.scrollView];
                         self.frameMarker.frame = CGRectMake(CGRectGetMaxX(changedFrameInSelfView),
                                                             0,
                                                             CGRectGetWidth(self.frameMarker.frame),
                                                             CGRectGetHeight(self.frameMarker.frame));
                     } completion:^(BOOL finished) {
                     }];
}

- (void)chunkCell:(GKVideoChunkCell *)chunkCell frameChangedOnLeftSide:(CGRect)changedFrame
{
    [self updateCellsFrameOnLeftSideFromCell:chunkCell.leftCell
                              toTailPosition:CGRectGetMinX(changedFrame) - self.cellEdge.left
                                   animation:NO
                                  completion:NULL];
    CGRect changedFrameInSelfView = [self convertRect:changedFrame fromView:self.scrollView];
    self.frameMarker.frame = CGRectMake(CGRectGetMinX(changedFrameInSelfView),
                                        0,
                                        CGRectGetWidth(self.frameMarker.frame),
                                        CGRectGetHeight(self.frameMarker.frame));
}

- (void)chunkCell:(GKVideoChunkCell *)chunkCell frameChangedOnRightSide:(CGRect)changedFrame
{
    [self updateCellsFrameOnRightSideFromCell:chunkCell.rightCell
                               toLeadPosition:CGRectGetMaxX(changedFrame) + self.cellEdge.right
                                    animation:NO
                                   completion:NULL];
    CGRect changedFrameInSelfView = [self convertRect:changedFrame fromView:self.scrollView];
    self.frameMarker.frame = CGRectMake(CGRectGetMaxX(changedFrameInSelfView),
                                        0,
                                        CGRectGetWidth(self.frameMarker.frame),
                                        CGRectGetHeight(self.frameMarker.frame));
}

- (void)chunkCell:(GKVideoChunkCell *)chunkCell changedByEditWithNewBeginTime:(NSTimeInterval)newBeginTime
       newEndTime:(NSTimeInterval)newEndTime
{
    if ([self.delegate respondsToSelector:@selector(horizontalScrollView:chunkCellDidEditAtIndex:beginTime:endTime:)]) {
        [self.delegate horizontalScrollView:self
                    chunkCellDidEditAtIndex:[self indexOfChunkCell:chunkCell]
                                  beginTime:chunkCell.cellModel.beginTime
                                    endTime:chunkCell.cellModel.endTime];
    }
}

- (void)chunkCell:(GKVideoChunkCell *)chunkCell didSplitAtTime:(NSTimeInterval)time
{
    if ([self.delegate respondsToSelector:@selector(horizontalScrollView:didSplitAtIndex:atTime:)]) {
        [self.delegate horizontalScrollView:self
                           didSplitAtIndex:[self indexOfChunkCell:chunkCell]
                                     atTime:time];
    }
}

- (void)didFinishEditForChunkCell:(GKVideoChunkCell *)chunkCell fromSide:(GKVideoChunkCellSide)side
{
    // Frame 变化了， 第一个 cell 的起点变化了， 需要重置。
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self setFrameMarkerToDefaultPostion];
                         [self updateCellsFrameOnRightSideFromCell:self.firstCell
                                                    toLeadPosition:[self offsetOfCurrentFrame]
                                                         animation:NO
                                                        completion:NULL];
                         [self adjustContentSizeAndOffset];
                         // 如果是在左边操作，那么将当前的 cell 的左边移到 currentFrame 点
                         if (side == GKVideoChunkCellSideLeft) {
                             [self scrollToOffset:CGRectGetMinX(chunkCell.frame)  - [self offsetOfCurrentFrame]
                                         animated:NO];
                         } else if (side == GKVideoChunkCellSideRight) {
                             [self scrollToOffset:CGRectGetMaxX(chunkCell.frame)  - [self offsetOfCurrentFrame]
                                         animated:NO];
                         }
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void)didChangeToEditWithTouchDownForChunkCell:(GKVideoChunkCell *)chunkCell
{
    [self scrollToOffset:CGRectGetMidX(chunkCell.frame) - [self offsetOfCurrentFrame]
                animated:YES];
}

#pragma mark - Update Cells Frame

/**
 * 更新 cell 及 cell 右边的cells， 起始点移动到 position
 */
- (void)updateCellsFrameOnRightSideFromCell:(GKHorizontalCell *)cell
                             toLeadPosition:(CGFloat)position
                                  animation:(BOOL)animation
                                 completion:(void (^)(BOOL finished))completion
{
    void(^actionBlock)() = ^() {
        GKHorizontalCell * curCell = cell;
        CGFloat xOffset = position;
        UIEdgeInsets cellEdge = self.cellEdge;
        while (curCell) {
            xOffset += cellEdge.left;
            
            curCell.frame = CGRectMake(xOffset,
                                       0,
                                       CGRectGetWidth(curCell.frame),
                                       CGRectGetHeight(curCell.frame));
            
            xOffset += CGRectGetWidth(curCell.frame);
            xOffset += cellEdge.right;
            
            // Next
            curCell = curCell.rightCell;
        }
    };
    static BOOL IN_MOVING_ANIMATION = NO;
    if (animation && IN_MOVING_ANIMATION == NO) {
        IN_MOVING_ANIMATION = YES;
        [UIView animateWithDuration:0.3f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             actionBlock();
                         } completion:^(BOOL finished) {
                             IN_MOVING_ANIMATION = NO;
                             if (completion) {
                                 completion(finished);
                             }
                         }];
    } else {
        actionBlock();
        if (completion) {
            completion(YES);
        }
    }
}

/**
 * 更新 cell 及 cell 左边的cells， 末尾点移动到 position
 */
- (void)updateCellsFrameOnLeftSideFromCell:(GKHorizontalCell *)cell
                            toTailPosition:(CGFloat)position
                                 animation:(BOOL)animation
                                completion:(void (^)(BOOL finished))completion
{
    void(^actionBlock)() = ^() {
        GKHorizontalCell * curCell = cell;
        CGFloat xOffset = position;
        UIEdgeInsets cellEdge = self.cellEdge;
        while (curCell) {
            xOffset -= cellEdge.right;
            
            curCell.frame = CGRectMake(xOffset - CGRectGetWidth(curCell.frame),
                                       0,
                                       CGRectGetWidth(curCell.frame),
                                       CGRectGetHeight(curCell.frame));
            
            xOffset -= CGRectGetWidth(curCell.frame);
            xOffset -= cellEdge.left;
            
            // Next
            curCell = curCell.leftCell;
        }
    };
    static BOOL IN_MOVING_ANIMATION = NO;
    if (animation && IN_MOVING_ANIMATION == NO) {
        IN_MOVING_ANIMATION = YES;
        [UIView animateWithDuration:0.3f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             actionBlock();
                         } completion:^(BOOL finished) {
                             IN_MOVING_ANIMATION = NO;
                             if (completion) {
                                 completion(finished);
                             }
                         }];
    } else {
        actionBlock();
        if (completion) {
            completion(YES);
        }
    }
}

@end
