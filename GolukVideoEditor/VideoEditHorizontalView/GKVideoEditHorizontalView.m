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

extern CGFloat HEIGHT_OF_HORIZONTAL_CELL;

@interface GKVideoEditHorizontalView ()
<
GKHorizontalScrollDataSource,
GKHorizontalScrollViewDelegate,
GKVideoHorizontalScrollViewLayout
>

@property (nonatomic, strong) GKVideoHorizontalScrollView * horizontalScrollView;
@property (nonatomic, weak  ) GKVideoChunkCell * selectedCell;

@property (nonatomic, weak  ) GKVideoTimeCellModel * timeCellModel;

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

- (void)divideCellAtCurrentFrame
{
    [self.horizontalScrollView attemptToDivideCellAtCurrentFrame];
}

- (void)updateCurrentFrameToTimeInterval:(NSTimeInterval)timeInterval
{
    [self updateCurrentFrameToTimeInterval:timeInterval animation:NO];
}

- (void)updateCurrentFrameToTimeInterval:(NSTimeInterval)timeInterval animation:(BOOL)animation
{
    [self.horizontalScrollView scrollToTimeInterval:timeInterval animated:animation];
}

- (void)refreshTotalDuration
{
    self.timeCellModel.totalDuration = [self.horizontalScrollView totalTimeDuration];
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
    [self.viewModel.innerCellModels addObject:[GKVideoAddChunkCellModel new]];
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
        return CGSizeMake(10, HEIGHT_OF_HORIZONTAL_CELL);
    } else if ([itemModel isKindOfClass:[GKVideoAddChunkCellModel class]]) {
        return CGSizeMake(HEIGHT_OF_HORIZONTAL_CELL, HEIGHT_OF_HORIZONTAL_CELL);
    } else if ([itemModel isKindOfClass:[GKVideoTailerCellModel class]]) {
        return CGSizeMake(HEIGHT_OF_HORIZONTAL_CELL, HEIGHT_OF_HORIZONTAL_CELL);
    } else if ([itemModel isKindOfClass:[GKVideoTimeCellModel class]]) {
        return CGSizeMake(HEIGHT_OF_HORIZONTAL_CELL, HEIGHT_OF_HORIZONTAL_CELL);
    }
    return CGSizeZero;
}

- (CGFloat)defaultOffsetOfFrameMarkerOfHorizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
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
cellModelAfterInterceptDividedModels:(NSArray *)cellModels
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

- (void)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView timeIntervalOfOffset:(CGFloat)timeInterval
{
    if ([self.delegate respondsToSelector:@selector(timeIntervalOfCurrentFrame:)]) {
        [self.delegate timeIntervalOfCurrentFrame:timeInterval];
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

@end
