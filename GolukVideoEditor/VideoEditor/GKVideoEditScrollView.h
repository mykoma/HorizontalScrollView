//
//  GKVideoEditScrollView.h
//  GolukVideoEditor
//
//  Created by apple on 16/4/11.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKHorizontalScrollView.h"
#import "GKVideoEditScrollViewModel.h"

@interface GKVideoEditScrollView : GKHorizontalScrollView

@property (nonatomic, strong) GKVideoEditScrollViewModel * viewModel;

@end
