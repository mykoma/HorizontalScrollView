//
//  GKVideoEditCell.m
//  GolukVideoEditor
//
//  Created by apple on 16/4/10.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKVideoEditCell.h"

@interface GKVideoEditCell ()

@property (nonatomic, assign) CGPoint priorPoint;
@property (nonatomic, assign, readwrite) CGRect originFrameInUpdating;

@end

@implementation GKVideoEditCell

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

- (void)setup
{
    if ([self canMove]) {
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongGesture:)];
        [self addGestureRecognizer:longGesture];
    }
}

- (GKVideoEditDirection)directionForCell:(GKVideoEditCell *)cell
{
    GKVideoEditDirection direction = GKVideoEditDirectionNone;
    GKVideoEditCell * tmpCell = self;
    // 检查右边
    while (tmpCell != nil) {
        if (tmpCell.rightCell == cell) {
            direction = GKVideoEditDirectionRight;
            break;
        }
        tmpCell = tmpCell.rightCell;
    }
    // 检查左边
    tmpCell = self;
    while (tmpCell != nil) {
        if (tmpCell.leftCell == cell) {
            direction = GKVideoEditDirectionLeft;
            break;
        }
        tmpCell = tmpCell.leftCell;
    }
    
    return direction;
}

- (void)changeRelationWithCell:(GKVideoEditCell *)cell
{
    GKVideoEditDirection direction = [self directionForCell:cell];
    
    if (direction != GKVideoEditDirectionNone) {
        // Move out for self.
        GKVideoEditCell * leftOfCurrentCell = self.leftCell;
        leftOfCurrentCell.rightCell = self.rightCell;
        self.rightCell.leftCell = leftOfCurrentCell;
    }
    
    if (direction == GKVideoEditDirectionLeft) {
        GKVideoEditCell * tmpCell = cell.leftCell;
        
        cell.leftCell = self;
        self.rightCell = cell;
        
        tmpCell.rightCell = self;
        self.leftCell = tmpCell;
    } else if (direction == GKVideoEditDirectionRight) {
        GKVideoEditCell * tmpCell = cell.rightCell;
        
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
            if ([self.delegate respondsToSelector:@selector(videoEditCell:moveBeganAtPoint:)]) {
                [self.delegate videoEditCell:self moveBeganAtPoint:point];
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint center = view.center;
            center.x += point.x - self.priorPoint.x;
            center.y += point.y - self.priorPoint.y;
            view.center = center;
            if ([self.delegate respondsToSelector:@selector(videoEditCell:movingAtPoint:)]) {
                [self.delegate videoEditCell:self movingAtPoint:center];
            }
            break;
        }
        case UIGestureRecognizerStateEnded: {
            if ([self.delegate respondsToSelector:@selector(videoEditCell:moveEndAtPoint:)]) {
                [self.delegate videoEditCell:self moveEndAtPoint:point];
            }
            break;
        }
        case UIGestureRecognizerStateCancelled: {
            if ([self.delegate respondsToSelector:@selector(videoEditCell:moveCanceledAtPoint:)]) {
                [self.delegate videoEditCell:self moveCanceledAtPoint:point];
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
