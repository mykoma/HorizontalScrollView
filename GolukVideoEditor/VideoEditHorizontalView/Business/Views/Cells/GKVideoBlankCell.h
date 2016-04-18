//
//  GKBlankCell.h
//  Goluk
//
//  Created by apple on 16/4/18.
//  Copyright © 2016年 Mobnotex. All rights reserved.
//

#import "GKHorizontalCell.h"

@interface GKVideoBlankCellModel : NSObject

@property (nonatomic, assign) CGSize size;

@end

@interface GKVideoBlankCell : GKHorizontalCell

@property (nonatomic, strong) GKVideoBlankCellModel * cellModel;

@end
