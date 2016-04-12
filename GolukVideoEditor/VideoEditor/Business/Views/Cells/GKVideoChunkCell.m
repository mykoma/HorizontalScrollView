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

@end

@implementation GKVideoChunkCell

- (void)setup
{
    [super setup];
    self.backgroundColor = [UIColor redColor];
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

+ (CGFloat)widthForModel:(GKVideoChunkCellModel *)cellModel
{
    CGFloat widthOfPicture = (16 * HEIGHT_OF_HORIZONTAL_CELL) / 9;
    CGFloat widthOfOneSecond = widthOfPicture / SECOND_COUNT_OF_ONE_PICTURE;
    return widthOfOneSecond * cellModel.duration * (cellModel.endPercent - cellModel.beginPercent);
}

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

@end
