//
//  GKVideoChunkFenceCell.h
//  GolukVideoEditor
//
//  Created by apple on 16/4/10.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKHorizontalCell.h"

@class GKVideoChunkCell;

@interface GKVideoChunkFenceCell : GKHorizontalCell

@property (nonatomic, weak) GKVideoChunkCell * leftChunkCell;
@property (nonatomic, weak) GKVideoChunkCell * rightChunkCell;

@end
