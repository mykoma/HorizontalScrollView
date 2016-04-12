//
//  GKVideoChunkCell.h
//  GolukVideoEditor
//
//  Created by apple on 16/4/10.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKVideoHorizontalCell.h"
#import "GKVideoChunkCellModel.h"

@class GKVideoFenceCell;

@interface GKVideoChunkCell : GKVideoHorizontalCell

@property (nonatomic, weak  ) GKVideoFenceCell * leftFenceCell;
@property (nonatomic, weak  ) GKVideoFenceCell * rightFenceCell;

@property (nonatomic, strong) GKVideoChunkCellModel * cellModel;

+ (CGFloat)widthForModel:(GKVideoChunkCellModel *)cellModel;

+ (CGFloat)widthOfOneSecond;

@end
