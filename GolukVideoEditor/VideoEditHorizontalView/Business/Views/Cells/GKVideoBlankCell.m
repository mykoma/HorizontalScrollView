//
//  GKBlankCell.m
//  Goluk
//
//  Created by apple on 16/4/18.
//  Copyright © 2016年 Mobnotex. All rights reserved.
//

#import "GKVideoBlankCell.h"

@implementation GKVideoBlankCell

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cellModel = [GKVideoBlankCellModel new];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end

@implementation GKVideoBlankCellModel

@end
