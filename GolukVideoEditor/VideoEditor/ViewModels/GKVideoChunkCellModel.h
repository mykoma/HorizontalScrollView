//
//  GKVideoChunkCellModel.h
//  GolukVideoEditor
//
//  Created by apple on 16/4/12.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GKVideoChunkCellModel : NSObject

@property (nonatomic, strong) NSMutableArray <UIImage *>    * images;
@property (nonatomic, assign) NSTimeInterval                duration;
@property (nonatomic, assign) CGFloat                       beginPercent;
@property (nonatomic, assign) CGFloat                       endPercent;

@end
