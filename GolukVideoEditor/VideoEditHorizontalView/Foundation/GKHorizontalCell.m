//
//  GKHorizontalCell.m
//  GolukVideoEditor
//
//  Created by apple on 16/4/10.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKHorizontalCell.h"

@interface GKHorizontalCell ()

@property (nonatomic, assign) CGPoint priorPoint;
@property (nonatomic, assign, readwrite) CGRect originFrameInUpdating;
@property (nonatomic, strong) UILongPressGestureRecognizer * longGesture;

@end

@implementation GKHorizontalCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)beginUpdating
{
    self.originFrameInUpdating = self.frame;
}


- (void)endUpdating
{
    self.originFrameInUpdating = CGRectZero;
}

- (void)setEnableMove:(BOOL)enableMove
{
    if (enableMove == NO) {
        [self removeGestureRecognizer:self.longGesture];
    } else {
        if (![self.gestureRecognizers containsObject:self.longGesture]) {
            if (self.longGesture == nil) {
                self.longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handleLongGesture:)];
            }
            [self addGestureRecognizer:self.longGesture];
        }
    }
}

- (void)setup
{
    if ([self canMove]) {
        self.enableMove = YES;
    }
}

- (NSArray *)divideAtRate:(CGFloat)rate
{
    // TODO
    return nil;
}

- (GKHorizontalDirection)directionForCell:(GKHorizontalCell *)cell
{
    GKHorizontalDirection direction = GKHorizontalDirectionNone;
    GKHorizontalCell * tmpCell = self;
    // 检查右边
    while (tmpCell != nil) {
        if (tmpCell.rightCell == cell) {
            direction = GKHorizontalDirectionRight;
            break;
        }
        tmpCell = tmpCell.rightCell;
    }
    // 检查左边
    tmpCell = self;
    while (tmpCell != nil) {
        if (tmpCell.leftCell == cell) {
            direction = GKHorizontalDirectionLeft;
            break;
        }
        tmpCell = tmpCell.leftCell;
    }
    
    return direction;
}

- (void)changeRelationWithCell:(GKHorizontalCell *)cell
{
    GKHorizontalDirection direction = [self directionForCell:cell];
    
    if (direction != GKHorizontalDirectionNone) {
        // Move out for self.
        GKHorizontalCell * leftOfCurrentCell = self.leftCell;
        leftOfCurrentCell.rightCell = self.rightCell;
        self.rightCell.leftCell = leftOfCurrentCell;
    }
    
    if (direction == GKHorizontalDirectionLeft) {
        GKHorizontalCell * tmpCell = cell.leftCell;
        
        cell.leftCell = self;
        self.rightCell = cell;
        
        tmpCell.rightCell = self;
        self.leftCell = tmpCell;
    } else if (direction == GKHorizontalDirectionRight) {
        GKHorizontalCell * tmpCell = cell.rightCell;
        
        cell.rightCell = self;
        self.leftCell = cell;
        
        tmpCell.leftCell = self;
        self.rightCell = tmpCell;
    }
}

#pragma mark - UIGestureRecognizer

- (void)handleLongGesture:(UILongPressGestureRecognizer *)sender
{
    UIView *view = sender.view;
    CGPoint point = [sender locationInView:view.superview];
    switch (sender.state) {
        case UIGestureRecognizerStatePossible: {
            break;
        }
        case UIGestureRecognizerStateBegan: {
            [view.superview bringSubviewToFront:view];
            if ([self.delegate respondsToSelector:@selector(horizontalCell:moveBeganAtPoint:)]) {
                [self.delegate horizontalCell:self moveBeganAtPoint:point];
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint center = view.center;
            center.x += point.x - self.priorPoint.x;
            center.y += point.y - self.priorPoint.y;
            view.center = center;
            if ([self.delegate respondsToSelector:@selector(horizontalCell:movingAtPoint:)]) {
                [self.delegate horizontalCell:self movingAtPoint:point];
            }
            break;
        }
        case UIGestureRecognizerStateEnded: {
            if ([self.delegate respondsToSelector:@selector(horizontalCell:moveEndAtPoint:)]) {
                [self.delegate horizontalCell:self moveEndAtPoint:point];
            }
            break;
        }
        case UIGestureRecognizerStateCancelled: {
            if ([self.delegate respondsToSelector:@selector(horizontalCell:moveCanceledAtPoint:)]) {
                [self.delegate horizontalCell:self moveCanceledAtPoint:point];
            }
            break;
        }
        case UIGestureRecognizerStateFailed: {
            
            break;
        }
    }
    self.priorPoint = point;
}

#pragma mark - Default Implement

- (BOOL)canMove
{
    return NO;
}

- (BOOL)canExchange
{
    return NO;
}

@end
