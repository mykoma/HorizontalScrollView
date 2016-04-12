//
//  GKVideoFenceCell.m
//  GolukVideoEditor
//
//  Created by apple on 16/4/10.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKVideoFenceCell.h"
#import "GKVideoChunkCell.h"

@implementation GKVideoFenceCell

- (void)setup
{
    [super setup];
    self.backgroundColor = [UIColor yellowColor];
}

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