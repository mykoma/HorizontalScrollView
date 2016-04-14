//
//  GKVideoChunkCell.m
//  GolukVideoEditor
//
//  Created by apple on 16/4/10.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKVideoChunkCell.h"
#import "GKVideoFenceCell.h"

CGFloat HEIGHT_OF_HORIZONTAL_CELL = 42;
NSInteger SECOND_COUNT_OF_ONE_PICTURE = 5;

@interface GKVideoChunkCell ()

@property (nonatomic, strong) UIButton * touchBtn;
@property (nonatomic, strong) NSMutableArray <UIImageView *> * imageIVs;

@end

@implementation GKVideoChunkCell

+ (CGFloat)widthOfOnePicture
{
    return (16 * HEIGHT_OF_HORIZONTAL_CELL) / 9;
}

+ (CGFloat)widthOfOneSecond
{
    CGFloat widthOfPicture = [self widthOfOnePicture];
    CGFloat widthOfOneSecond = widthOfPicture / SECOND_COUNT_OF_ONE_PICTURE;
    return widthOfOneSecond;
}

+ (CGFloat)widthForModel:(GKVideoChunkCellModel *)cellModel
{
    return [[self class] widthOfOneSecond] * cellModel.duration * (cellModel.endPercent - cellModel.beginPercent);
}

- (void)setup
{
    [super setup];
    self.clipsToBounds = YES;
    self.imageIVs = [NSMutableArray new];
    
    self.touchBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self addSubview:self.touchBtn];
    
    [self.touchBtn addTarget:self
                      action:@selector(touchDown:)
            forControlEvents:UIControlEventTouchDown];
    
    self.backgroundColor = [UIColor greenColor];
}

- (void)setCellModel:(GKVideoChunkCellModel *)cellModel
{
    _cellModel = cellModel;
    [self.imageIVs enumerateObjectsUsingBlock:^(UIImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self.imageIVs removeAllObjects];
    
    NSInteger imageCount = ceil(self.cellModel.duration / SECOND_COUNT_OF_ONE_PICTURE);
    NSInteger indexOfImage = 0;
    for (NSInteger index = 0; index < imageCount; index ++) {
        indexOfImage = index;
        if (indexOfImage >= cellModel.images.count) {
            indexOfImage = cellModel.images.count - 1;
        }
        if (indexOfImage >= 0 && indexOfImage < self.cellModel.images.count) {
            UIImage * image = self.cellModel.images[indexOfImage];
            UIImageView * imageIV = [[UIImageView alloc] initWithImage:image];
            [self.imageIVs addObject:imageIV];
            [self insertSubview:imageIV
                   belowSubview:self.touchBtn];
        }
    }
}

- (void)layoutSubviews
{
    self.touchBtn.frame = self.bounds;

    UIImageView * prevIV = nil;
    for (UIImageView * imageView in self.imageIVs) {
        imageView.frame = CGRectMake(CGRectGetMaxX(prevIV.frame) - [self offsetOfImageIV],
                                     0,
                                     [[self class] widthOfOnePicture],
                                     HEIGHT_OF_HORIZONTAL_CELL);
        prevIV = imageView;
    }
}

- (CGFloat)offsetOfImageIV
{
    return [[self class] widthOfOneSecond] * (self.cellModel.duration * self.cellModel.beginPercent);
}

#pragma mark - Setter & Getter

- (void)setLeftFenceCell:(GKVideoFenceCell *)leftFenceCell
{
    self.leftCell = leftFenceCell;
}

- (GKVideoFenceCell *)leftFenceCell
{
    return (GKVideoFenceCell *)self.leftCell;
}

- (void)setRightFenceCell:(GKVideoFenceCell *)rightFenceCell
{
    self.rightCell = rightFenceCell;
}

- (GKVideoFenceCell *)rightFenceCell
{
    return (GKVideoFenceCell *)self.rightCell;
}

#pragma mark - Actions

- (void)touchDown:(id)sender
{
    if (self.touchDown) {
        self.touchDown();
    }
}

#pragma mark - Override

- (void)changeRelationWithCell:(GKVideoChunkCell *)cell
{
    GKHorizontalDirection direction = [self directionForCell:cell];

    if (direction == GKHorizontalDirectionLeft) {
        GKHorizontalCell * fenceCell = self.leftCell;
        // 连接右边两个 cell
        self.rightCell.leftCell = fenceCell.leftCell;
        fenceCell.leftCell.rightCell = self.rightCell;
        // 连接左边4个 cell
        
        GKHorizontalCell * tempFenceCell = cell.leftCell;
        tempFenceCell.rightCell = self;
        self.leftCell = tempFenceCell;
        
        self.rightCell = fenceCell;
        fenceCell.leftCell = self;
        
        cell.leftCell = fenceCell;
        fenceCell.rightCell = cell;
    } else if (direction == GKHorizontalDirectionRight) {
        GKHorizontalCell * fenceCell = self.rightFenceCell;
        // 连接左边两个 cell
        self.leftCell.rightCell = fenceCell.rightCell;
        fenceCell.rightCell.leftCell = self.leftCell;
        
        // 连接右边4个 cell
        GKHorizontalCell * tempFenceCell = cell.rightCell;
        tempFenceCell.leftCell = self;
        self.rightCell = tempFenceCell;
        
        fenceCell.rightCell = self;
        self.leftCell = fenceCell;
        
        fenceCell.leftCell = cell;
        cell.rightCell = fenceCell;
    }
}

- (BOOL)canMove
{
    return YES;
}

- (BOOL)canExchange
{
    return YES;
}

- (NSArray *)divideAtRate:(CGFloat)rate
{
    CGFloat visibleDuration = self.cellModel.duration * (self.cellModel.endPercent - self.cellModel.beginPercent);
    CGFloat leftInvisibleDuration = self.cellModel.duration * self.cellModel.beginPercent;
    CGFloat leftSubVisibleDuration = visibleDuration * rate;
    CGFloat rightSubVisibleDuration = visibleDuration - leftSubVisibleDuration;
    CGFloat rightInvisibleDuration = self.cellModel.duration * (1.0f - self.cellModel.endPercent);

    // Left
    GKVideoChunkCellModel * leftSubCellModel = [GKVideoChunkCellModel new];
    leftSubCellModel.duration = leftInvisibleDuration + leftSubVisibleDuration;
    leftSubCellModel.beginPercent = leftInvisibleDuration / leftSubCellModel.duration;
    // endPercent 只会是 1.0f
    leftSubCellModel.endPercent = 1.0f;
    // 计算图片的最大 index
    NSInteger ceilImageIndex = ceil(leftSubCellModel.duration / SECOND_COUNT_OF_ONE_PICTURE);
    NSMutableArray <UIImage *> * mArray = [NSMutableArray new];
    NSInteger indexOfImage = 0;
    for (NSInteger index = 0; index < ceilImageIndex; index ++) {
        indexOfImage = index;
        if (indexOfImage >= self.cellModel.images.count) {
            indexOfImage = self.cellModel.images.count - 1;
        }
        if (indexOfImage >= 0 && indexOfImage < self.cellModel.images.count) {
            [mArray addObject:self.cellModel.images[indexOfImage]];
        }
    }
    leftSubCellModel.images = mArray;

    // Right
    GKVideoChunkCellModel * rightSubCellModel = [GKVideoChunkCellModel new];
    rightSubCellModel.duration = rightSubVisibleDuration + rightInvisibleDuration;
    // beginPercent 只会是 0.0f
    rightSubCellModel.beginPercent = 0.0f;
    rightSubCellModel.endPercent = rightSubVisibleDuration / rightSubCellModel.duration;
    // 计算图片的起始 index
    NSInteger floorImageIndex = floor(leftSubCellModel.duration / SECOND_COUNT_OF_ONE_PICTURE);
    // 计算需要几张图片
    NSInteger needImageCount = ceil(rightSubCellModel.duration / SECOND_COUNT_OF_ONE_PICTURE);
    NSInteger index = 0;
    indexOfImage = 0;
    mArray = [NSMutableArray new];
    while (index < needImageCount) {
        indexOfImage = index + floorImageIndex;
        if (indexOfImage >= self.cellModel.images.count) {
            indexOfImage = self.cellModel.images.count - 1;
        }
        if (indexOfImage >= 0 && indexOfImage < self.cellModel.images.count) {
            [mArray addObject:self.cellModel.images[indexOfImage]];
        }
        index ++;
    }
    rightSubCellModel.images = mArray;
    
    return @[leftSubCellModel, rightSubCellModel];
}

@end
