//
//  GKVideoEditScrollViewModel.m
//  GolukVideoEditor
//
//  Created by apple on 16/4/12.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKVideoEditScrollViewModel.h"

@implementation GKVideoEditScrollViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _chunkCellModels = [NSMutableArray new];
        _innerCellModels = [NSMutableArray new];
    }
    return self;
}

@end
