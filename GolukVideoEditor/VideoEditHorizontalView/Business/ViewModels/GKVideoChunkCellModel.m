//
//  GKVideoChunkCellModel.m
//  GolukVideoEditor
//
//  Created by apple on 16/4/12.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKVideoChunkCellModel.h"

@implementation GKVideoChunkCellModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _beginTime = 0.0f;
        _endTime = 0.0f;
        _duration = 0.0f;
    }
    return self;
}

- (NSTimeInterval)endTime
{
    if (_endTime <= 0.0f) {
        _endTime = self.duration;
    }
    return _endTime;
}

@end
