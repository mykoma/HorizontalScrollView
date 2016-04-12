//
//  GKVideoChunkTimeCell.h
//  GolukVideoEditor
//
//  Created by apple on 16/4/12.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKHorizontalCell.h"

@interface GKVideoChunkTimeCellModel : NSObject

@end

@interface GKVideoChunkTimeCell : GKHorizontalCell

@property (nonatomic, strong) GKVideoChunkTimeCellModel * cellModel;

@end
