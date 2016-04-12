//
//  GKVideoFenceCell.h
//  GolukVideoEditor
//
//  Created by apple on 16/4/10.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKVideoHorizontalCell.h"

@class GKVideoChunkCell;

@interface GKVideoFenceCellModel : NSObject

@end

@interface GKVideoFenceCell : GKVideoHorizontalCell

@property (nonatomic, strong) GKVideoFenceCellModel * cellModel;

@property (nonatomic, weak) GKVideoChunkCell * leftChunkCell;
@property (nonatomic, weak) GKVideoChunkCell * rightChunkCell;

@end
