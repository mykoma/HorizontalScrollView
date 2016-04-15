//
//  GKVideoTimeCell.h
//  GolukVideoEditor
//
//  Created by apple on 16/4/12.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKHorizontalCell.h"

@interface GKVideoTimeCellModel : NSObject

@property (nonatomic, assign) NSTimeInterval totalDuration;

@end

@interface GKVideoTimeCell : GKHorizontalCell

@property (nonatomic, strong) GKVideoTimeCellModel * cellModel;

@end
