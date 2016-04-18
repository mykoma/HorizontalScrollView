//
//  GKVideoFenceCell.m
//  GolukVideoEditor
//
//  Created by apple on 16/4/10.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKVideoFenceCell.h"
#import "GKVideoChunkCell.h"

CGFloat WIDTH_OF_FENCE_CELL = 23;

CGFloat WIDTH_OF_FENCE_CELL_CENTER = 3;
CGFloat HEIGHT_OF_FENCE_CELL_CENTER = 27;

@interface GKVideoFenceCell ()

@property (nonatomic, strong) UIView * centerView;

@end

@implementation GKVideoFenceCell

- (void)setup
{
    [super setup];
    self.backgroundColor = [UIColor clearColor];
    self.centerView = [[UIView alloc] init];
    self.centerView.backgroundColor = [UIColor colorWithRed:0x2f/255.0f
                                                      green:0x30/255.0f
                                                       blue:0x31/255.0f
                                                      alpha:1];
    [self addSubview:self.centerView];
}

- (void)layoutSubviews
{
    self.centerView.frame = CGRectMake((CGRectGetWidth(self.bounds) - WIDTH_OF_FENCE_CELL_CENTER) / 2,
                                       (CGRectGetHeight(self.bounds) - HEIGHT_OF_FENCE_CELL_CENTER) / 2,
                                       WIDTH_OF_FENCE_CELL_CENTER,
                                       HEIGHT_OF_FENCE_CELL_CENTER);
    self.centerView.layer.cornerRadius = WIDTH_OF_FENCE_CELL_CENTER / 2;
}

#pragma mark - Setter & Getter

- (void)setLeftChunkCell:(GKVideoChunkCell *)leftChunkCell
{
    self.leftCell = leftChunkCell;
}

- (GKVideoChunkCell *)leftChunkCell
{
    return (GKVideoChunkCell *)self.leftCell;
}

- (void)setRightChunkCell:(GKVideoChunkCell *)rightChunkCell
{
    self.rightCell = rightChunkCell;
}

- (GKVideoChunkCell *)rightChunkCell
{
    return (GKVideoChunkCell *)self.rightCell;
}

#pragma mark - Override

- (BOOL)skipWhenScroll
{
    return YES;
}

@end

@implementation GKVideoFenceCellModel

@end
