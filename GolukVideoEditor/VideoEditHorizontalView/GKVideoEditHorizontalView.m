//
//  GKVideoEditHorizontalView.m
//  GolukVideoEditor
//
//  Created by apple on 16/4/12.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKVideoEditHorizontalView.h"
#import "GKVideoChunkCell.h"
#import "GKVideoFenceCell.h"
#import "GKVideoAddChunkCell.h"
#import "GKVideoTailerCell.h"
#import "GKVideoTimeCell.h"
#import "GKVideoBlankCell.h"

extern CGFloat HEIGHT_OF_HORIZONTAL_CELL;
extern CGFloat WIDTH_OF_FENCE_CELL;

@interface GKVideoEditHorizontalView ()
<
GKHorizontalScrollDataSource,
GKHorizontalScrollViewDelegate,
GKVideoHorizontalScrollViewLayout
>

@property (nonatomic, strong) GKVideoHorizontalScrollView * horizontalScrollView;
@property (nonatomic, weak  ) GKVideoChunkCell * selectedCell;
@property (nonatomic, weak  ) GKVideoTimeCellModel * timeCellModel;
@property (nonatomic, assign, readwrite) NSUInteger selectedIndex;

@end

@implementation GKVideoEditHorizontalView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.viewModel = [[GKVideoEditHorizontalViewModel alloc] init];
        
        self.horizontalScrollView = [[GKVideoHorizontalScrollView alloc] initWithFrame:self.bounds];
        self.horizontalScrollView.dataSource = self;
        self.horizontalScrollView.delegate = self;
        self.horizontalScrollView.layout = self;
        [self addSubview:self.horizontalScrollView];
    }
    return self;
}

- (void)loadData
{
    [self buildInnerViewModels];
    [self.horizontalScrollView reloadData];
    [self refreshTotalDuration];
}

- (void)addChunkCellModel:(GKVideoChunkCellModel *)cellModel
{
    [self.horizontalScrollView appendCellModel:cellModel];
    [self refreshTotalDuration];
}

- (void)removeSelectedCell
{
    if (self.selectedCell) {
        [self.horizontalScrollView removeCell:self.selectedCell];
    } else {
        NSLog(@"删除的 cell 的不能是nil");
    }
}

- (void)splitCellAtCurrentFrame
{
    [self.horizontalScrollView attemptToSplitCellAtCurrentFrame];
}

- (void)updateCurrentFrameToTimeInterval:(NSTimeInterval)timeInterval
{
    [self.horizontalScrollView scrollToTimeInterval:timeInterval animated:NO];
}

- (void)refreshTotalDuration
{
    self.timeCellModel.totalDuration = [self.horizontalScrollView totalTimeDuration];
}

- (void)resetToNormalState
{
    [self.horizontalScrollView resetToNormalState];
}

- (GKVideoHorizontalState)state
{
    return self.horizontalScrollView.state;
}

#pragma mark - ViewModel

- (void)buildInnerViewModels
{
    [self.viewModel.innerCellModels removeAllObjects];
    
    for (GKVideoChunkCellModel * chunkCellModel in self.viewModel.chunkCellModels) {
        [self.viewModel.innerCellModels addObject:chunkCellModel];
        [self.viewModel.innerCellModels addObject:[GKVideoFenceCellModel new]];
    }
    
    [self.viewModel.innerCellModels addObject:[GKVideoTailerCellModel new]];
    
    GKVideoBlankCellModel * blankCellModel = [GKVideoBlankCellModel new];
    blankCellModel.size = CGSizeMake(19.0f, HEIGHT_OF_HORIZONTAL_CELL);
    [self.viewModel.innerCellModels addObject:blankCellModel];
    
    [self.viewModel.innerCellModels addObject:[GKVideoAddChunkCellModel new]];
    
    blankCellModel = [GKVideoBlankCellModel new];
    blankCellModel.size = CGSizeMake(11.0f, HEIGHT_OF_HORIZONTAL_CELL);
    [self.viewModel.innerCellModels addObject:blankCellModel];

    GKVideoTimeCellModel * timeCellModel = [GKVideoTimeCellModel new];
    self.timeCellModel = timeCellModel;
    
    [self.viewModel.innerCellModels addObject:timeCellModel];
}

#pragma mark - GKVideoHorizontalScrollDataSource

- (GKHorizontalCell *)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
                          cellForItemModel:(id)itemModel
{
    if ([itemModel isKindOfClass:[GKVideoChunkCellModel class]]) {
        GKVideoChunkCell * cell = [[GKVideoChunkCell alloc] init];
        cell.cellModel = itemModel;
        __weak typeof(self) weakSelf = self;
        __weak typeof(cell) weakCell = cell;
        [cell setTouchDown:^ {
            // TODO
        }];
        [cell setVisibleChanged:^{
            [weakSelf refreshTotalDuration];
        }];
        [cell setStateChangedToEdit:^{
            weakSelf.selectedCell = weakCell;
        }];
        return cell;
    } else if ([itemModel isKindOfClass:[GKVideoFenceCellModel class]]) {
        return [[GKVideoFenceCell alloc] init];
    } else if ([itemModel isKindOfClass:[GKVideoAddChunkCellModel class]]) {
        GKVideoAddChunkCell * cell = [[GKVideoAddChunkCell alloc] init];
        __weak typeof(self) weakSelf = self;
        [cell setTouchAction:^{
            if ([weakSelf.delegate respondsToSelector:@selector(didTouchAddChunk)]) {
                [weakSelf.delegate didTouchAddChunk];
            }
        }];
        return cell;
    } else if ([itemModel isKindOfClass:[GKVideoTailerCellModel class]]) {
        return [[GKVideoTailerCell alloc] init];
    } else if ([itemModel isKindOfClass:[GKVideoTimeCellModel class]]) {
        GKVideoTimeCell * cell = [[GKVideoTimeCell alloc] init];
        cell.cellModel = itemModel;
        return cell;
    }
    return [[GKHorizontalCell alloc] init];
}

#pragma mark - GKHorizontalScrollDataSource

- (NSInteger)countOfHorizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
{
    return self.viewModel.innerCellModels.count;
}

- (GKHorizontalCell *)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
                     cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cellModel = self.viewModel.innerCellModels[indexPath.row];
    return [((GKVideoHorizontalScrollView *)horizontalScrollView).dataSource horizontalScrollView:horizontalScrollView
                                                                                 cellForItemModel:cellModel];
}

#pragma mark - GKVideoHorizontalScrollViewLayout

- (CGSize)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
              sizeForItemModel:(id)itemModel
{
    if ([itemModel isKindOfClass:[GKVideoChunkCellModel class]]) {
        return CGSizeMake([GKVideoChunkCell widthForModel:itemModel], HEIGHT_OF_HORIZONTAL_CELL);
    } else if ([itemModel isKindOfClass:[GKVideoFenceCellModel class]]) {
        return CGSizeMake(WIDTH_OF_FENCE_CELL, HEIGHT_OF_HORIZONTAL_CELL);
    } else if ([itemModel isKindOfClass:[GKVideoAddChunkCellModel class]]) {
        return CGSizeMake(75, HEIGHT_OF_HORIZONTAL_CELL);
    } else if ([itemModel isKindOfClass:[GKVideoTailerCellModel class]]) {
        return CGSizeMake(75, HEIGHT_OF_HORIZONTAL_CELL);
    } else if ([itemModel isKindOfClass:[GKVideoTimeCellModel class]]) {
        return CGSizeMake(48, HEIGHT_OF_HORIZONTAL_CELL);
    } else if ([itemModel isKindOfClass:[GKVideoBlankCellModel class]]) {
        GKVideoBlankCellModel * blankCellModel = (GKVideoBlankCellModel *)itemModel;
        return blankCellModel.size;
    }
    return CGSizeZero;
}

- (CGFloat)defaultOffsetOfCurrentFrameOfHorizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
{
    if ([horizontalScrollView.layout respondsToSelector:@selector(edgeInsetsOfHorizontalScrollView:)]) {
        return [horizontalScrollView.layout edgeInsetsOfHorizontalScrollView:horizontalScrollView].left;
    }
    return 50;
}

#pragma mark - GKHorizontalScrollViewLayout

- (CGRect)rectOfScrollView:(GKHorizontalScrollView *)horizontalScrollView
{
    return CGRectMake(0,
                      CGRectGetMidY(self.bounds) - HEIGHT_OF_HORIZONTAL_CELL / 2,
                      CGRectGetWidth(self.bounds), HEIGHT_OF_HORIZONTAL_CELL);
}

- (CGSize)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
        sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id cellModel = self.viewModel.innerCellModels[indexPath.row];
    if ([horizontalScrollView isKindOfClass:[GKVideoHorizontalScrollView class]]) {
        return [((GKVideoHorizontalScrollView *)horizontalScrollView).layout horizontalScrollView:horizontalScrollView
                                                                                 sizeForItemModel:cellModel];
    }
    return CGSizeZero;
}

- (UIEdgeInsets)edgeInsetsOfHorizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
{
    return UIEdgeInsetsMake(0, CGRectGetMidX(self.bounds), 0, 10);
}

- (UIEdgeInsets)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
             insetForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark - GKVideoHorizontalScrollViewDelegate

- (NSArray *)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
cellModelAfterInterceptSplitdModels:(NSArray *)cellModels
{
    NSAssert(cellModels.count == 2, nil);
    return @[cellModels[0],
             [GKVideoFenceCellModel new],
             cellModels[1]];
}

- (NSArray *)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
cellModelAfterInterceptAppendModels:(NSArray *)cellModels
{
    NSMutableArray * mArray = [NSMutableArray new];
    for (id cellModel in cellModels) {
        if ([cellModel isKindOfClass:[GKVideoChunkCellModel class]]) {
            [mArray addObject:cellModel];
            [mArray addObject:[GKVideoFenceCellModel new]];
        }
    }
    return mArray;
}

- (void)horizontalScrollViewBeganScrollByManual:(GKHorizontalScrollView *)horizontalScrollView
{
    if ([self.delegate respondsToSelector:@selector(scrollAreaBeganScrollByManual)]) {
        [self.delegate scrollAreaBeganScrollByManual];
    }
}

- (void)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView timeIntervalOfScrollOffset:(CGFloat)timeInterval
{
    if ([self.delegate respondsToSelector:@selector(timeIntervalAtCurrentFrame:)]) {
        [self.delegate timeIntervalAtCurrentFrame:timeInterval];
    }
}

- (void)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
   chunkCellDidDeleteAtIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(chunkCellDidDeleteAtIndex:)]) {
        [self.delegate chunkCellDidDeleteAtIndex:index];
    }
    [self refreshTotalDuration];
}

- (void)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
      chunkCellMoveFromIndex:(NSInteger)fromIndex
                     toIndex:(NSInteger)toIndex
{
    if ([self.delegate respondsToSelector:@selector(chunkCellMovedFromIndex:toIndex:)]) {
        [self.delegate chunkCellMovedFromIndex:fromIndex toIndex:toIndex];
    }
}

- (void)didTouchDownBackground:(GKHorizontalScrollView *)horizontalScrollView
{
    if ([self.delegate respondsToSelector:@selector(didTouchDownBackground)]) {
        [self.delegate didTouchDownBackground];
    }
}

- (void)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
               changeStateTo:(GKVideoHorizontalState)state
{
    if (state == GKVideoHorizontalStateNormal) {
        self.selectedCell = nil;
    }
    if ([self.delegate respondsToSelector:@selector(didChangeToState:)]) {
        [self.delegate didChangeToState:state];
    }
}

- (void)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
chunkCellOfCurrentFrameChangedAtIndex:(NSInteger)index
{
    self.selectedIndex = index;
    if ([self.delegate respondsToSelector:@selector(chunkCellOfCurrentFrameChangedAtIndex:)]) {
        [self.delegate chunkCellOfCurrentFrameChangedAtIndex:index];
    }
}

- (void)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
    couldSplitAtCurrentFrame:(BOOL)couldSplit
{
    if ([self.delegate respondsToSelector:@selector(couldSplitAtCurrentFrame:)]) {
        [self.delegate couldSplitAtCurrentFrame:couldSplit];
    }
}

- (void)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
            didSplitAtIndex:(NSInteger)index
                      atTime:(NSTimeInterval)time
{
    if ([self.delegate respondsToSelector:@selector(didSplitAtIndex:atTime:)]) {
        [self.delegate didSplitAtIndex:index atTime:time];
    }
}

- (void)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
     chunkCellDidEditAtIndex:(NSInteger)index
                   beginTime:(NSTimeInterval)beginTime
                     endTime:(NSTimeInterval)endTime
{
    if ([self.delegate respondsToSelector:@selector(didEditChunkCellAtIndex:beginTime:endTime:)]) {
        [self.delegate didEditChunkCellAtIndex:index
                                     beginTime:beginTime
                                       endTime:endTime];
    }
}

- (void)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
  chunkCellInEdittingAtIndex:(NSInteger)index
                   beginTime:(NSTimeInterval)beginTime
                     endTime:(NSTimeInterval)endTim
{
    [self refreshTotalDuration];
}

@end
