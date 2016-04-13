//
//  GKVideoTailerCell.h
//  GolukVideoEditor
//
//  Created by apple on 16/4/12.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKHorizontalCell.h"

@interface GKVideoTailerCellModel : NSObject

@end

@interface GKVideoTailerCell : GKHorizontalCell

@property (nonatomic, strong) GKVideoTailerCellModel * cellModel;

@end
