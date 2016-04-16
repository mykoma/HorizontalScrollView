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

@interface GKVideoHorizontalScrollView () <GKVideoChunkCellDelegate>

@property (nonatomic, strong) UIImageView      * frameMarker;
@property (nonatomic, assign) GKVideoHorizontalState state;

@end

@implementation GKVideoHorizontalScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _frameMarker = [[UIImageView alloc] init];
        _frameMarker.backgroundColor = [UIColor redColor];
        _state = GKVideoHorizontalStateNormal;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(chunkCellBecomeEdit:)
                                                     name:GK_VIDEO_CHUNK_CELL_NOTIFICATION_BECOME_EDIT
                                                   object:nil];
        
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
    [self refreshContentSize];
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

- (void)attemptToDivideCellAtCurrentFrame
{
    [self attemptToDivideCellWithLeftDistance:[self offsetOfCurrentFrame]];
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
                         [self adjustContentSizeAndOffset];
                     }];
}

- (void)attemptToDivideCellWithLeftDistance:(CGFloat)distance
{
    GKHorizontalCell * cell = [self seekCellWithLeftDistance:distance];
    
    // 如果不是GKVideoChunkCell
    if (![cell isKindOfClass:[GKVideoChunkCell class]]) {
        return;
    }
    
    // 计算offset 在 cell 中的比率
    CGFloat leftWidth = ([self offsetOfCurrentFrame] + self.scrollView.contentOffset.x - CGRectGetMinX(cell.frame));
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
    cell.rightCell.leftCell = prevCell;
    prevCell.rightCell = cell.rightCell;
    
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
        CGFloat durationOfRate = curCell.cellModel.endPercent - curCell.cellModel.beginPercent;
        // 如果在这个 curCell 的duration中间
        if (additionTimeInterval <= timeInterval
            && timeInterval <= additionTimeInterval + curCell.cellModel.duration * durationOfRate) {
            break;
        }
        additionTimeInterval += curCell.cellModel.duration * durationOfRate;
        
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
        CGFloat durationOfRate = curCell.cellModel.endPercent - curCell.cellModel.beginPercent;
        totalDuration += durationOfRate * curCell.cellModel.duration;
        
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

- (void)horizontalScrollViewDidScroll:(UIScrollView *)scrollView
{
    [super horizontalScrollViewDidScroll:scrollView];
    // 如果是编辑状态，那么当 cell 改变的时候， 如果当前 currentFrame 的 cell 没有被选中， 那么选中。
    if (self.state == GKVideoHorizontalStateEdit) {
        GKHorizontalCell * cell = [self seekCellWithLeftDistance:[self offsetOfCurrentFrame]];
        if ([cell isKindOfClass:[GKVideoChunkCell class]]) {
            [(GKVideoChunkCell *)cell becomeToEditState];
        }
    }
    if ([self.delegate respondsToSelector:@selector(horizontalScrollView:timeIntervalOfOffset:)])
    {
        NSTimeInterval timeInterval = [self timeIntervalOfHorizontalScrollOffset:scrollView.contentOffset.x];
        [self.delegate horizontalScrollView:self timeIntervalOfOffset:timeInterval];
    }
}

- (void)didTouchDownBackground
{
    [super didTouchDownBackground];
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
    GKHorizontalCell * cell = [self seekCellWithLeftDistance:[self offsetOfCurrentFrame]];

    NSTimeInterval timeInterval = 0.0f;
    GKHorizontalCell * curCell = cell.leftCell;
    while (curCell) {
        if ([curCell isKindOfClass:[GKVideoChunkCell class]]) {
            GKVideoChunkCell * chunkCell = (GKVideoChunkCell *)curCell;
            CGFloat durationOfRate = chunkCell.cellModel.endPercent - chunkCell.cellModel.beginPercent;
            timeInterval += chunkCell.cellModel.duration * durationOfRate;
        }
        curCell = curCell.leftCell;
    }

    if ([cell isKindOfClass:[GKVideoChunkCell class]]) {
        GKVideoChunkCell * chunkCell = (GKVideoChunkCell *)cell;
        timeInterval += [chunkCell timeIntervalOfVisibleOffset:([self offsetOfCurrentFrame] + offset - CGRectGetMinX(cell.frame))];
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

- (void)chunkCell:(GKVideoChunkCell *)chunkCell leftEditMovedOffset:(CGFloat)offset
{
    NSLog(@"--- %lf", offset);
}

- (void)chunkCell:(GKVideoChunkCell *)chunkCell rightEditMovedOffset:(CGFloat)offset
{
    NSLog(@"--- %lf", offset);
}

- (void)didChangeToEditWithTouchDownForChunkCell:(GKVideoChunkCell *)chunkCell
{
    [self scrollToOffset:CGRectGetMidX(chunkCell.frame) - [self offsetOfCurrentFrame]
                animated:YES];
}

@end
