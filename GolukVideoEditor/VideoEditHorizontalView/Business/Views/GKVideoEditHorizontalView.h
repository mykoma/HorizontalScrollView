//
//  GKVideoEditHorizontalView.h
//  GolukVideoEditor
//
//  Created by apple on 16/4/12.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKVideoHorizontalScrollView.h"
#import "GKVideoEditHorizontalViewModel.h"

@interface GKVideoEditHorizontalView : UIView

@property (nonatomic, strong) GKVideoEditHorizontalViewModel * viewModel;

@property (nonatomic, copy) void (^addChunkAction)();

- (void)loadData;
- (void)addChunkCellModel:(GKVideoChunkCellModel *)cellModel;
- (void)removeSelectedCell;
- (void)divideCellAtCurrentFrame;

// TO DELETE
- (void)updateTemp;
- (void)updateTempAnimation;

@end
