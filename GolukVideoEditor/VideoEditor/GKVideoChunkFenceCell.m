//
//  GKVideoChunkFenceCell.m
//  GolukVideoEditor
//
//  Created by apple on 16/4/10.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKVideoChunkFenceCell.h"
#import "GKVideoChunkCell.h"

@implementation GKVideoChunkFenceCell

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

@end

@implementation GKVideoChunkFenceCellModel

@end
