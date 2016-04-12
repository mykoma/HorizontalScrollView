//
//  GKVideoTailerCell.h
//  GolukVideoEditor
//
//  Created by apple on 16/4/12.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKVideoHorizontalCell.h"

@interface GKVideoTailerCellModel : NSObject

@end

@interface GKVideoTailerCell : GKVideoHorizontalCell

@property (nonatomic, strong) GKVideoTailerCellModel * cellModel;

@end
