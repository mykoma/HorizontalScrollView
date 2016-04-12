//
//  GKVideoTimeCell.h
//  GolukVideoEditor
//
//  Created by apple on 16/4/12.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKVideoHorizontalCell.h"

@interface GKVideoTimeCellModel : NSObject

@end

@interface GKVideoTimeCell : GKVideoHorizontalCell

@property (nonatomic, strong) GKVideoTimeCellModel * cellModel;

@end
