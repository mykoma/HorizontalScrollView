//
//  GKVideoEditScrollViewModel.h
//  GolukVideoEditor
//
//  Created by apple on 16/4/12.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GKVideoChunkCellModel.h"

@interface GKVideoEditHorizontalViewModel : NSObject

/**
 * 当前视频帧的时间
 */
@property (nonatomic, assign) NSTimeInterval timeIntervalOfFrame;

/**
 * 外部传入的 chunk cell model
 */
@property (nonatomic, strong) NSMutableArray <GKVideoChunkCellModel *> * chunkCellModels;
/**
 * 封装过后的内部 cellModels
 */
@property (nonatomic, strong) NSMutableArray * innerCellModels;

@end
