//
//  GKVideoEditHorizontalView.m
//  GolukVideoEditor
//
//  Created by apple on 16/4/12.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKVideoEditHorizontalView.h"
#import "GKVideoHorizontalScrollView.h"
#import "GKVideoChunkCell.h"
#import "GKVideoFenceCell.h"
#import "GKVideoAddChunkCell.h"
#import "GKVideoTailerCell.h"
#import "GKVideoTimeCell.h"

extern CGFloat HEIGHT_OF_HORIZONTAL_CELL;

@interface GKVideoEditHorizontalView ()
<
GKHorizontalScrollDataSource,
GKHorizontalScrollViewLayout,
GKHorizontalScrollViewDelegate
>

@property (nonatomic, strong) GKVideoHorizontalScrollView * scrollView;

@end

@implementation GKVideoEditHorizontalView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.viewModel = [[GKVideoEditHorizontalViewModel alloc] init];
        
        self.scrollView = [[GKVideoHorizontalScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.dataSource = self;
        self.scrollView.delegate = self;
        self.scrollView.layout = self;
        [self addSubview:self.scrollView];
    }
    return self;
}

- (void)loadData
{
    [self buildInnerViewModels];
    [self.scrollView reloadData];
}

- (void)updateTemp
{
    [self.scrollView scrollToTimeInterval:self.viewModel.timeIntervalOfFrame animated:NO];
}

- (void)updateTempAnimation
{
    [self.scrollView scrollToTimeInterval:self.viewModel.timeIntervalOfFrame animated:YES];
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
    [self.viewModel.innerCellModels addObject:[GKVideoTimeCellModel new]];
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
    if ([cellModel isKindOfClass:[GKVideoChunkCellModel class]]) {
        GKVideoChunkCell * cell = [[GKVideoChunkCell alloc] init];
        cell.cellModel = cellModel;
        return cell;
    } else if ([cellModel isKindOfClass:[GKVideoFenceCellModel class]]) {
        return [[GKVideoFenceCell alloc] init];
    } else if ([cellModel isKindOfClass:[GKVideoAddChunkCellModel class]]) {
        return [[GKVideoAddChunkCell alloc] init];
    } else if ([cellModel isKindOfClass:[GKVideoTailerCellModel class]]) {
        return [[GKVideoTailerCell alloc] init];
    } else if ([cellModel isKindOfClass:[GKVideoTimeCellModel class]]) {
        return [[GKVideoTimeCell alloc] init];
    }
    return [[GKHorizontalCell alloc] init];
}

#pragma mark - GKHorizontalScrollViewLayout

- (CGRect)rectOfHorizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
{
    return CGRectMake(0, 50, CGRectGetWidth(self.frame), HEIGHT_OF_HORIZONTAL_CELL);
}

- (CGSize)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
        sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id cellModel = self.viewModel.innerCellModels[indexPath.row];
    if ([cellModel isKindOfClass:[GKVideoChunkCellModel class]]) {
        return CGSizeMake([GKVideoChunkCell widthForModel:cellModel], HEIGHT_OF_HORIZONTAL_CELL);
    } else if ([cellModel isKindOfClass:[GKVideoFenceCellModel class]]) {
        return CGSizeMake(10, HEIGHT_OF_HORIZONTAL_CELL);
    } else if ([cellModel isKindOfClass:[GKVideoAddChunkCellModel class]]) {
        return CGSizeMake(HEIGHT_OF_HORIZONTAL_CELL, HEIGHT_OF_HORIZONTAL_CELL);
    } else if ([cellModel isKindOfClass:[GKVideoTailerCellModel class]]) {
        return CGSizeMake(HEIGHT_OF_HORIZONTAL_CELL, HEIGHT_OF_HORIZONTAL_CELL);
    } else if ([cellModel isKindOfClass:[GKVideoTimeCellModel class]]) {
        return CGSizeMake(HEIGHT_OF_HORIZONTAL_CELL, HEIGHT_OF_HORIZONTAL_CELL);
    }
    return CGSizeZero;
}

- (UIEdgeInsets)edgeInsetsOfHorizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
{
    return UIEdgeInsetsMake(0, 50, 0, 10);
}

- (UIEdgeInsets)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
             insetForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return UIEdgeInsetsMake(0, 0, 0, 5);
}

@end
