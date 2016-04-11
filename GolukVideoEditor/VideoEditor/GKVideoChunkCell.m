//
//  GKVideoChunkCell.m
//  GolukVideoEditor
//
//  Created by apple on 16/4/10.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKVideoChunkCell.h"

@interface GKVideoChunkCell ()

@end

@implementation GKVideoChunkCell

- (void)setup
{
    [super setup];
    self.backgroundColor = [UIColor redColor];
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
