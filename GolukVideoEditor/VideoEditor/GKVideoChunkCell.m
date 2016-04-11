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

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    [super setup];
    self.backgroundColor = [UIColor redColor];
    
}

@end
