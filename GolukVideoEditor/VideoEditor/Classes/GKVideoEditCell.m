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
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongGesture:)];
    [self addGestureRecognizer:longGesture];
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
            if ([self.delegate respondsToSelector:@selector(videoEditCell:changeCenter:)]) {
                [self.delegate videoEditCell:self changeCenter:center];
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

@end
