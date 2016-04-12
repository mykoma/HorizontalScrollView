//
//  GKVideoChunkCell.h
//  GolukVideoEditor
//
//  Created by apple on 16/4/10.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKHorizontalCell.h"
#import "GKVideoChunkCellModel.h"

@class GKVideoChunkFenceCell;

@interface GKVideoChunkCell : GKHorizontalCell

@property (nonatomic, weak  ) GKVideoChunkFenceCell * leftFenceCell;
@property (nonatomic, weak  ) GKVideoChunkFenceCell * rightFenceCell;

@property (nonatomic, strong) GKVideoChunkCellModel * cellModel;

@end
