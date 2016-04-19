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
NSTimeInterval MIN_EDIT_SECOND_DURATION = 2.0f;

@interface GKVideoChunkCell ()

@property (nonatomic, assign) GKVideoChunkCellState state;
@property (nonatomic, strong) NSMutableArray <UIImageView *> * imageIVs;
@property (nonatomic, strong) UIView * leftEditView;
@property (nonatomic, strong) UIView * rightEditView;
@property (nonatomic, strong) UIView * topEditLine;
@property (nonatomic, strong) UIView * bottomEditLine;
@property (nonatomic, strong) UIView * centerEditView;
@property (nonatomic, strong) UILabel * centerEditLabel;

@end

@implementation GKVideoChunkCell

#pragma mark - Class Method

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

+ (NSTimeInterval)durationOfWidth:(CGFloat)width
{
    return width / [[self class] widthOfOneSecond];
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
    return [[self class] widthOfOneSecond] * (cellModel.endTime - cellModel.beginTime);
}

#pragma mark - Life Circle

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

#pragma mark - Public

- (void)becomeToEditState
{
    if (self.state == GKVideoChunkCellStateNormal) {
        self.state = GKVideoChunkCellStateEdit;
        if (self.stateChangedToEdit) {
            self.stateChangedToEdit();
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:GK_VIDEO_CHUNK_CELL_NOTIFICATION_BECOME_EDIT
                                                            object:self];
    }
}

#pragma mark - Lazy Load

- (UIView *)centerEditView
{
    if (_centerEditView == nil) {
        _centerEditView = [[UIView alloc] init];
        _centerEditView.backgroundColor = [[self class] editColor];
        _centerEditView.alpha = 0.5f;
    }
    return _centerEditView;
}

- (UILabel *)centerEditLabel
{
    if (_centerEditLabel == nil) {
        _centerEditLabel = [[UILabel alloc] init];
        _centerEditLabel.textAlignment = NSTextAlignmentCenter;
        _centerEditLabel.font = [UIFont systemFontOfSize:13.0f];
    }
    return _centerEditLabel;
}

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

#pragma mark - Layout

- (void)layoutSubviews
{
    UIImageView * prevIV = nil;
    CGFloat xOffset = 0.0f - [self offsetOfVisibelImageIV];
    for (UIImageView * imageView in self.imageIVs) {
        imageView.frame = CGRectMake(xOffset,
                                     0,
                                     [[self class] widthOfOnePicture],
                                     HEIGHT_OF_HORIZONTAL_CELL);
        xOffset += CGRectGetWidth(imageView.frame);
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

//    [UIView animateWithDuration:0.1f
//                          delay:0
//                        options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
    _leftEditView.alpha    = 0.0f;
    _rightEditView.alpha   = 0.0f;
    _topEditLine.alpha    = 0.0f;
    _bottomEditLine.alpha = 0.0f;
    _centerEditView.alpha = 0.0f;
    _centerEditLabel.alpha = 0.0f;
//                     } completion:^(BOOL finished) {
                         // 这儿不调用 self. 是为了避免调用懒加载
    [_leftEditView removeFromSuperview];
    [_rightEditView removeFromSuperview];
    [_topEditLine removeFromSuperview];
    [_bottomEditLine removeFromSuperview];
    [_centerEditView removeFromSuperview];
    [_centerEditLabel removeFromSuperview];
//                     }];
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
    self.centerEditView.frame = CGRectMake(CGRectGetMaxX(self.leftEditView.frame),
                                           CGRectGetMaxY(self.topEditLine.frame),
                                           CGRectGetMinX(self.rightEditView.frame) - CGRectGetMaxX(self.leftEditView.frame),
                                           CGRectGetMinY(self.bottomEditLine.frame) - CGRectGetMaxY(self.topEditLine.frame));
    [self.centerEditLabel sizeToFit];
    self.centerEditLabel.center = CGPointMake(CGRectGetMidX(self.bounds),
                                              CGRectGetMidY(self.bounds));
    [self addSubview:self.leftEditView];
    [self addSubview:self.rightEditView];
    [self addSubview:self.topEditLine];
    [self addSubview:self.bottomEditLine];
    [self addSubview:self.centerEditView];
    [self addSubview:self.centerEditLabel];
//    [UIView animateWithDuration:0.1f
//                          delay:0
//                        options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
    self.leftEditView.alpha    = 1.0f;
    self.rightEditView.alpha   = 1.0f;
    self.topEditLine.alpha    = 1.0f;
    self.bottomEditLine.alpha = 1.0f;
    self.centerEditView.alpha = 0.5f;
    self.centerEditLabel.alpha = 1.0f;
//                     } completion:^(BOOL finished) {
//                     }];
}

#pragma mark - Setter & Getter

- (void)setCellModel:(GKVideoChunkCellModel *)cellModel
{
    [_cellModel removeObserver:self
                    forKeyPath:@"beginTime"];
    [_cellModel removeObserver:self
                    forKeyPath:@"endTime"];
    
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
    
    [_cellModel addObserver:self
                 forKeyPath:@"beginTime"
                    options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                    context:NULL];
    [_cellModel addObserver:self
                 forKeyPath:@"endTime"
                    options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                    context:NULL];
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
    GKVideoChunkCellState recordState = self.state;
    [self becomeToEditState];
    if (recordState == GKVideoChunkCellStateNormal) {
        if ([self.chunkCellDelegate respondsToSelector:@selector(didChangeToEditWithTouchDownForChunkCell:)]) {
            [self.chunkCellDelegate didChangeToEditWithTouchDownForChunkCell:self];
        }
    }
    if (self.touchDown) {
        self.touchDown();
    }
}

#pragma mark - Gesture

- (void)leftEditGestureMoved:(UIPanGestureRecognizer *)sender
{
    BOOL(^updateFrameWhenChange)(void) = ^() {
        CGPoint point = [sender locationInView:self.superview];
        if (point.x >= CGRectGetMaxX(self.frame)) {
            return NO;
        }
        CGRect newFrame = CGRectMake(point.x, 0,
                                     CGRectGetMaxX(self.frame) - point.x,
                                     CGRectGetHeight(self.frame));
        NSTimeInterval newBeginTime = self.cellModel.endTime - (CGRectGetMaxX(newFrame) - CGRectGetMinX(newFrame)) / [[self class] widthOfOneSecond];
        if (newBeginTime < 0.0f
            || (self.cellModel.endTime - newBeginTime) < MIN_EDIT_SECOND_DURATION) {
            return NO;
        }
        self.cellModel.beginTime = newBeginTime;
        self.frame = newFrame;
        return YES;
    };
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            if (!updateFrameWhenChange()) {
                return;
            }
            if ([self.chunkCellDelegate respondsToSelector:@selector(chunkCell:frameBeganChangedOnLeftSide:)]) {
                [self.chunkCellDelegate chunkCell:self frameBeganChangedOnLeftSide:self.frame];
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if (!updateFrameWhenChange()) {
                return;
            }
            if ([self.chunkCellDelegate respondsToSelector:@selector(chunkCell:frameChangedOnLeftSide:)]) {
                [self.chunkCellDelegate chunkCell:self frameChangedOnLeftSide:self.frame];
            }
            break;
        }
        case UIGestureRecognizerStateEnded: {
            if ([self.chunkCellDelegate respondsToSelector:@selector(didFinishEditForChunkCell:fromSide:)]) {
                [self.chunkCellDelegate didFinishEditForChunkCell:self fromSide:GKVideoChunkCellSideLeft];
            }
            break;
        }
        default:
            break;
    }
}

- (void)rightEditGestureMoved:(UITapGestureRecognizer *)sender
{
    BOOL(^updateFrameWhenChange)(void) = ^() {
        CGPoint point = [sender locationInView:self.superview];
        if (CGRectGetMinX(self.frame) >= point.x) {
            return NO;
        }
        CGRect newFrame = CGRectMake(CGRectGetMinX(self.frame), 0,
                                     point.x - CGRectGetMinX(self.frame),
                                     CGRectGetHeight(self.frame));
        NSTimeInterval newEndTime = (CGRectGetMaxX(newFrame) - CGRectGetMinX(newFrame)) / [[self class] widthOfOneSecond] + self.cellModel.beginTime;
        if (newEndTime > self.cellModel.duration
            || (newEndTime - self.cellModel.beginTime) < MIN_EDIT_SECOND_DURATION) {
            return NO;
        }
        
        self.cellModel.endTime = newEndTime;
        self.frame = newFrame;
        return YES;
    };

    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            if (!updateFrameWhenChange()) {
                return;
            }
            if ([self.chunkCellDelegate respondsToSelector:@selector(chunkCell:frameBeganChangedOnRightSide:)]) {
                [self.chunkCellDelegate chunkCell:self frameBeganChangedOnRightSide:self.frame];
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if (!updateFrameWhenChange()) {
                return;
            }
            if ([self.chunkCellDelegate respondsToSelector:@selector(chunkCell:frameChangedOnRightSide:)]) {
                [self.chunkCellDelegate chunkCell:self frameChangedOnRightSide:self.frame];
            }
            break;
        }
        case UIGestureRecognizerStateEnded: {
            if ([self.chunkCellDelegate respondsToSelector:@selector(didFinishEditForChunkCell:fromSide:)]) {
                [self.chunkCellDelegate didFinishEditForChunkCell:self fromSide:GKVideoChunkCellSideRight];
            }
            break;
        }
        default:
            break;
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
    CGFloat visibleDuration = (self.cellModel.endTime - self.cellModel.beginTime);
    CGFloat leftInvisibleDuration = self.cellModel.beginTime;
    CGFloat leftSubVisibleDuration = visibleDuration * rate;
    CGFloat rightSubVisibleDuration = visibleDuration - leftSubVisibleDuration;
    CGFloat rightInvisibleDuration = self.cellModel.duration - self.cellModel.endTime;

    // Left
    GKVideoChunkCellModel * leftSubCellModel = [GKVideoChunkCellModel new];
    leftSubCellModel.duration = leftInvisibleDuration + leftSubVisibleDuration;
    leftSubCellModel.beginTime = leftInvisibleDuration;
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
    // beginTime 只会是 0.0f
    rightSubCellModel.beginTime = 0.0f;
    rightSubCellModel.endTime = rightSubVisibleDuration;
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

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"beginTime"] || [keyPath isEqualToString:@"endTime"]) {
        self.centerEditLabel.text = [NSString stringWithFormat:@"%.1lf″", self.cellModel.endTime - self.cellModel.beginTime];
    }
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

#pragma mark - Private

- (CGFloat)offsetOfVisibelImageIV
{
    return [[self class] widthOfOneSecond] * self.cellModel.beginTime;
}

- (NSTimeInterval)timeIntervalOfVisibleOffset:(CGFloat)offset
{
    return offset / [[self class] widthOfOneSecond];
}

@end
