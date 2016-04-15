//
//  GKVideoChunkCell.m
//  GolukVideoEditor
//
//  Created by apple on 16/4/10.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKVideoChunkCell.h"
#import "GKVideoFenceCell.h"

NSString * GK_VIDEO_CHUNK_CELL_NOTIFICATION_RESIGN_EDIT = @"com.goluk.videoEditor.resign.edit";
NSString * GK_VIDEO_CHUNK_CELL_NOTIFICATION_BECOME_EDIT = @"com.goluk.videoEditor.become.edit";

CGFloat HEIGHT_OF_HORIZONTAL_CELL = 42;
NSInteger SECOND_COUNT_OF_ONE_PICTURE = 5;

@interface GKVideoChunkCell ()

@property (nonatomic, assign) GKVideoChunkCellState state;
@property (nonatomic, strong) NSMutableArray <UIImageView *> * imageIVs;
@property (nonatomic, strong) UIView * leftEditView;
@property (nonatomic, strong) UIView * rightEditView;
@property (nonatomic, strong) UIView * topEditLine;
@property (nonatomic, strong) UIView * bottomEditLine;

@end

@implementation GKVideoChunkCell

+ (UIColor *)editColor
{
    static UIColor * editColor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        editColor = [UIColor colorWithRed:0xff/255.0f
                                    green:0xcc/255.0f
                                     blue:0x00/255.0f
                                    alpha:1];
    });
    return editColor;
}

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

+ (void)resignEditState
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GK_VIDEO_CHUNK_CELL_NOTIFICATION_RESIGN_EDIT
                                                        object:nil];
}

+ (CGFloat)widthForModel:(GKVideoChunkCellModel *)cellModel
{
    return [[self class] widthOfOneSecond] * cellModel.duration * (cellModel.endPercent - cellModel.beginPercent);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setup
{
    [super setup];
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleResignEditNotification:)
                                                 name:GK_VIDEO_CHUNK_CELL_NOTIFICATION_RESIGN_EDIT
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleBecomeEditNotification:)
                                                 name:GK_VIDEO_CHUNK_CELL_NOTIFICATION_BECOME_EDIT
                                               object:nil];
    self.imageIVs = [NSMutableArray new];
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(touchDown:)];
    [self addGestureRecognizer:tapGesture];
    
}

#pragma mark - Lazy Load

- (UIView *)leftEditView
{
    if (_leftEditView == nil) {
        _leftEditView = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftEditView.backgroundColor = [[self class] editColor];
        UIPanGestureRecognizer * gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                   action:@selector(leftEditGestureMoved:)];
        [_leftEditView addGestureRecognizer:gesture];
    }
    return _leftEditView;
}

- (UIView *)rightEditView
{
    if (_rightEditView == nil) {
        _rightEditView = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightEditView.backgroundColor = [[self class] editColor];

        UIPanGestureRecognizer * gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                   action:@selector(rightEditGestureMoved:)];
        [_rightEditView addGestureRecognizer:gesture];
    }
    return _rightEditView;
}

- (UIView *)topEditLine
{
    if (_topEditLine == nil) {
        _topEditLine = [[UIView alloc] init];
        _topEditLine.backgroundColor = [[self class] editColor];
    }
    return _topEditLine;
}

- (UIView *)bottomEditLine
{
    if (_bottomEditLine == nil) {
        _bottomEditLine = [[UIView alloc] init];
        _bottomEditLine.backgroundColor = [[self class] editColor];
    }
    return _bottomEditLine;
}

#pragma mark - Notifications

- (void)handleResignEditNotification:(NSNotification *)notification
{
    self.state = GKVideoChunkCellStateNormal;
    self.enableMove = YES;
}

- (void)handleBecomeEditNotification:(NSNotification *)notification
{
    if (notification.object != self) {
        self.state = GKVideoChunkCellStateNormal;
    }
    self.enableMove = NO;
}

#pragma mark -

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
            [self addSubview:imageIV];
        }
    }
}

- (void)setState:(GKVideoChunkCellState)state
{
    if (_state == state) {
        return;
    }
    _state = state;
    // 状态变化， 需要重新刷新 subviews 的 frame
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    UIImageView * prevIV = nil;
    for (UIImageView * imageView in self.imageIVs) {
        imageView.frame = CGRectMake(CGRectGetMaxX(prevIV.frame) - [self offsetOfImageIV],
                                     0,
                                     [[self class] widthOfOnePicture],
                                     HEIGHT_OF_HORIZONTAL_CELL);
        prevIV = imageView;
    }

    if (self.state == GKVideoChunkCellStateNormal) {
        [self layoutForNormalState];
    } else if (self.state == GKVideoChunkCellStateEdit) {
        [self layoutForEditState];
    }
}

- (void)layoutForNormalState
{
    self.layer.cornerRadius = 0.0f;

    [UIView animateWithDuration:0.1f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _leftEditView.alpha    = 0.0f;
                         _rightEditView.alpha   = 0.0f;
                         _topEditLine.alpha    = 0.0f;
                         _bottomEditLine.alpha = 0.0f;
                     } completion:^(BOOL finished) {
                         // 这儿不调用 self. 是为了避免调用懒加载
                         [_leftEditView removeFromSuperview];
                         [_rightEditView removeFromSuperview];
                         [_topEditLine removeFromSuperview];
                         [_bottomEditLine removeFromSuperview];
                     }];
}

- (void)layoutForEditState
{
    static CGFloat editBtnWidth = 10.0f;
    static CGFloat editLineHeight = 1.0f;
    self.layer.cornerRadius = 4.0f;
    
    self.leftEditView.alpha    = 0.0f;
    self.rightEditView.alpha   = 0.0f;
    self.topEditLine.alpha    = 0.0f;
    self.bottomEditLine.alpha = 0.0f;
    
    self.leftEditView.frame = CGRectMake(0, 0,
                                         editBtnWidth,
                                         CGRectGetHeight(self.bounds));
    self.rightEditView.frame = CGRectMake(CGRectGetWidth(self.bounds) - editBtnWidth,
                                          0,
                                          editBtnWidth,
                                          CGRectGetHeight(self.bounds));
    self.topEditLine.frame = CGRectMake(0, 0,
                                        CGRectGetWidth(self.bounds),
                                        editLineHeight);
    self.bottomEditLine.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - editLineHeight,
                                           CGRectGetWidth(self.bounds),
                                           editLineHeight);
    [self addSubview:self.leftEditView];
    [self addSubview:self.rightEditView];
    [self addSubview:self.topEditLine];
    [self addSubview:self.bottomEditLine];
    [UIView animateWithDuration:0.1f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.leftEditView.alpha    = 1.0f;
                         self.rightEditView.alpha   = 1.0f;
                         self.topEditLine.alpha    = 1.0f;
                         self.bottomEditLine.alpha = 1.0f;
                     } completion:^(BOOL finished) {
                     }];
}

- (CGFloat)offsetOfImageIV
{
    return [[self class] widthOfOneSecond] * (self.cellModel.duration * self.cellModel.beginPercent);
}

- (NSTimeInterval)timeIntervalOfVisibleOffset:(CGFloat)offset
{
    return offset / [[self class] widthOfOneSecond];
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
    if (self.state == GKVideoChunkCellStateNormal) {
        self.state = GKVideoChunkCellStateEdit;
        [[NSNotificationCenter defaultCenter] postNotificationName:GK_VIDEO_CHUNK_CELL_NOTIFICATION_BECOME_EDIT
                                                            object:self];
    }
    if (self.touchDown) {
        self.touchDown();
    }
}

#pragma mark - Gesture

- (void)leftEditGestureMoved:(id)sender
{
    // TODO
}

- (void)rightEditGestureMoved:(id)sender
{
    // TODO
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
